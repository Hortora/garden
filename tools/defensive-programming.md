# Defensive Programming Techniques

---

## Add a corruption signature check after text transformations that could silently garble content

**ID:** GE-0009
**Stack:** Python (general pattern — language-agnostic)
**Labels:** `#strategy` `#defensive`
**What it achieves:** Prevents serving corrupted content to users when a text transformation silently produces wrong output instead of raising an error.
**Context:** Any transformation of user-visible text — prettifying, encoding, templating, markdown rendering — where the output could be silently wrong (no exception raised, no error logged, valid-looking output that is semantically broken).

### The technique
After transforming text, check for a known corruption signature and fall back to the original input if detected:

```python
content = transform(raw)

# Silent garbling has no exception to catch — check for a known-bad signature
CORRUPTION_SIGNATURE = 'ÃÂÃÂ'  # BeautifulSoup lxml double-encoding pattern
if CORRUPTION_SIGNATURE in content:
    log.warning(
        'transform() produced garbled output — falling back to raw input. '
        'Check the transformer configuration.'
    )
    content = raw
```

In a web server context:
```python
content = BeautifulSoup(raw, 'html.parser').prettify()
if 'ÃÂÃÂ' in content or '\xc3\x82' in content:
    print(f'WARNING: prettify produced garbled content — falling back to raw HTML.')
    content = raw
```

The corruption signature should be a string that:
- Appears reliably in corrupted output
- Never appears in valid output of that type
- Is specific enough to avoid false positives

### Why this is non-obvious
Most developers either trust the transformation (it's a library, it should work) or catch exceptions (try/except around the call). Silent garbling — where the output is syntactically valid text but semantically wrong — has no exception to catch and produces no error. Without an explicit check, corrupted content reaches users silently, often only discovered when a user reports "weird characters" in the UI. The signature check is the only automated guard for this failure mode.

### When to use it
- After any prettify / format / encode step on content with non-ASCII characters (user data, archived content, international text)
- When the transformation involves a third-party library whose encoding behaviour depends on configuration
- As a **defense-in-depth layer** alongside the correct fix — not as a substitute for fixing the root cause
- The fallback (returning raw input) is always safe when the raw is already valid for the downstream consumer

**See also:** GE-0018 for testing this at every pipeline layer.

*Score: 11/15 · Included because: pattern fills the gap between "catch exceptions" and "trust the library" for silent failures; concrete implementation makes it actionable · Reservation: "validate transformation output" is a known principle; the concrete corruption-signature form is less so*

---

## Test encoding correctness at every pipeline layer with a shared garbling-signature helper

**ID:** GE-0018
**Stack:** Python, pytest, Playwright — general pattern for any text-transformation pipeline
**Labels:** `#testing` `#defensive` `#strategy`
**What it achieves:** Catches encoding regressions at every stage independently — not just "the function returns clean output" but "the file on disk is clean", "HTTP serves it clean", and "the browser renders it clean". Prevents the cycle of "tests pass, user still sees garbling".
**Context:** A pipeline that converts HTML → Markdown via BeautifulSoup + html2text + file writes + HTTP serving. Multiple encoding bugs were found at different stages. Unit tests on the conversion function passed while the file on disk was garbled.

### The technique

**1. Centralise all known garbling signatures into one assertion helper:**

```python
GARBLING_SIGNATURES = [
    'ÃÂÃÂ',    # Pattern A: lxml double-encoding via <meta charset>
    'Ã¢Â',     # Pattern B: triple-encoding (lxml output re-encoded again)
    'â€',       # Pattern C: UTF-8 decoded as Windows-1252
]

def assert_not_garbled(text: str, label: str = ''):
    prefix = f'{label}: ' if label else ''
    for sig in GARBLING_SIGNATURES:
        assert sig not in text, (
            f'{prefix}Garbling pattern {repr(sig)} found. '
            f'Check that html.parser (not lxml) is used throughout.'
        )
```

**2. Test each pipeline layer independently:**

```python
# Layer 1: function output (unit test — no server needed)
def test_function_output_not_garbled(tmp_path):
    result = convert_html_to_markdown(html_path)
    assert_not_garbled(result, 'function_output')

# Layer 2: disk file (integration — confirms server writes correctly)
def test_disk_file_not_garbled(session, md_dir):
    session.post(f'{API}/posts/{slug}/generate-md')
    content = (md_dir / f'{slug}.md').read_text(encoding='utf-8')
    assert_not_garbled(content, 'disk_file')

# Layer 3: HTTP response (catches Content-Type/encoding issues in serving)
def test_http_response_not_garbled(session):
    r = session.get(f'{SERVER}/output/{slug}.md')
    assert_not_garbled(r.text, 'http_response')

# Layer 4: browser render (catches cache + rendering issues)
def test_browser_render_not_garbled():  # Playwright
    page.goto(f'{SERVER}/ui/')
    # ... navigate to the post ...
    assert_not_garbled(page.locator('#content').inner_text(), 'browser')
```

**3. Use a real file with non-ASCII content, not a synthetic fixture:**

```python
def test_real_post_not_garbled():
    html_path = posts_dir / '2006-05-31-what-is-a-rule-engine.html'
    if not html_path.exists():
        pytest.skip('Legacy posts not available')
    result = convert_html_to_markdown(html_path)
    assert_not_garbled(result, 'real_post')
```

Synthetic fixtures often miss encoding bugs that only surface with real file content and complex HTML structure.

### Why this is non-obvious

Most developers test the conversion function and stop there. But the full pipeline has at least 4 independent failure points for encoding:
1. The conversion function itself
2. The file write (`write_text(content)` — is `encoding='utf-8'` specified?)
3. The HTTP server (`Content-Type: text/plain` without charset may cause browser misinterpretation)
4. The browser (cache may serve old garbled content even after the file is fixed)

Each layer requires its own test. A unit test on the function cannot catch a `write_text()` with wrong encoding. A disk-file test cannot catch browser cache. Only the Playwright test catches the full end-to-end path.

### When to use it
Any pipeline that transforms text through multiple steps (parse → transform → write → serve → render):
- HTML-to-Markdown converters
- Template engines writing to disk
- API responses cached by CDN
- Any server-rendered content with non-ASCII characters

**See also:** GE-0009 for the corruption signature check pattern. GE-0015 for the browser cache failure mode specifically.

*Score: 13/15 (merge assessment) · Included because: closes the "tests pass, user still sees bug" gap that unit-only testing leaves; the layered approach is not documented as a pattern · Reservation: Playwright tests require setup; Layer 4 is slowest*
