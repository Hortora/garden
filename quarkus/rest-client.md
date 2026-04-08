# Quarkus REST Client Gotchas

---

## Quarkus REST client silently fails JSON deserialisation without quarkus-rest-client-reactive-jackson

**Stack:** Quarkus 3.9.x, quarkus-rest, quarkus-rest-client
**Symptom:** REST client throws: `"Response could not be mapped to type java.util.List<Foo> for response with media type application/json. Hints: Consider adding quarkus-rest-client-reactive-jackson or quarkus-rest-client-reactive-jsonb"`. Server returns valid JSON; `curl` against the same endpoint works correctly.
**Context:** Using `@RegisterRestClient` with the Quarkus REST stack (not Resteasy Reactive) to consume JSON endpoints. Occurs whenever the client tries to deserialise a JSON response into a Java type.

### What was tried (didn't work)
- Confirmed server returns valid JSON (curl and browser both show correct response)
- Added `@Produces(MediaType.APPLICATION_JSON)` to the client interface — no effect
- Added a Jackson `ObjectMapper` CDI bean — no effect
- Tried `@Consumes(MediaType.APPLICATION_JSON)` on the client — no effect

### Root cause
`quarkus-rest-client` does not bundle a JSON provider. Jackson-based JSON deserialisation for REST client responses is in a separate Quarkus extension that must be added explicitly. Without it, the client has no way to convert a JSON response body into a Java object, so it throws a mapping error.

### Fix
Add to `pom.xml`:

```xml
<dependency>
  <groupId>io.quarkus</groupId>
  <artifactId>quarkus-rest-client-reactive-jackson</artifactId>
</dependency>
```

No code changes are required — the extension auto-configures Jackson as the JSON provider for all REST clients. Despite the word "reactive" in the extension name, this is the correct extension for the non-reactive `quarkus-rest` stack.

### Why this is non-obvious
The error message mentions "media type" which strongly implies a content negotiation problem, leading developers to add `@Produces`/`@Consumes` annotations that do nothing. The fix hint is buried at the end of the error message and easy to miss. Worse, the extension name says "reactive" — when using the non-reactive Quarkus REST stack, a developer would reasonably assume this extension doesn't apply to them and dismiss it. It does apply, the name is just misleading.
