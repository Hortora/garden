# Observability — Implementation Patterns

**Domain tags:** `observability` `logging` `tracing` `metrics` `mdc` `opentelemetry`  
**Last reviewed:** 2026-05-29

For concepts (what/why, three pillars, key terms): [observability.md](observability.md)

---

## Structured Logging

**Enable for production, disable for dev/test:**
```
production: JSON format (machine-parseable by Kibana, Loki, Datadog, Splunk)
dev/test:   plain text (human-readable)
```

**Log level guidance:**
- `ERROR` — failures requiring intervention
- `WARN` — degraded but functional states
- `INFO` — significant business events (default in production)
- `DEBUG` — never in production globally; use per-package scoping for investigation

**Always include context — never log sensitive data:**
```
✅ LOG.infof("Processing case caseId=%s workflowId=%s", caseId, workflowId)
❌ LOG.infof("User email=%s password=%s", email, password)
```
Never log passwords, tokens, API keys, PII, payment details.

---

## MDC / Correlation ID Pattern

**Setup (at request entry point):**
1. Generate or extract correlation ID from incoming request header
2. Store in MDC (mapped diagnostic context) — thread/context-local
3. All subsequent log calls automatically include it
4. Propagate to downstream services via HTTP headers

**Essential MDC fields:**
| Field | Purpose |
|-------|---------|
| `requestId` / `correlationId` | Unique ID for this request |
| `userId` | Authenticated user (if applicable) |
| `sessionId` | Groups requests in same session |
| `instanceId` | Workflow/operation instance |
| `taskId` | Current step in multi-step operation |

**Querying by correlation in aggregators:**
```
Kibana/OpenSearch:  mdc.requestId: "abc-123"
Loki/Grafana:       {app="myapp"} | json | mdc_requestId="abc-123"
Datadog:            @mdc.requestId:abc-123
```

---

## HTTP Header Propagation

Propagate correlation IDs to all downstream HTTP calls:

| Header | Maps to |
|--------|---------|
| `X-Request-ID` / `X-Correlation-ID` | `requestId` MDC field |
| `X-Session-ID` | `sessionId` MDC field |

**Pattern:**
1. Extract from incoming request header
2. Store in MDC
3. Add to all outgoing HTTP requests automatically
4. Downstream services extract and log — enables end-to-end correlation

Disable if a strict downstream API rejects unknown headers.

---

## OpenTelemetry Setup

```xml
<!-- Add dependency -->
<dependency>
  <groupId>io.opentelemetry</groupId>
  <!-- or framework-specific: io.quarkus:quarkus-opentelemetry -->
</dependency>
```

```properties
# Collector endpoint
otel.exporter.otlp.endpoint=http://localhost:4317

# Service identification (appears in trace UIs)
otel.resource.attributes=service.name=my-service

# Disable in dev/test if no collector running
%dev.otel.sdk.disabled=true
%test.otel.sdk.disabled=true
```

**Custom spans — instrument significant business operations only:**
```java
@WithSpan("myapp.processOrder")
public Result processOrder(@SpanAttribute("order.id") String orderId) { ... }
```
Don't annotate every method — only meaningful business operations.
Over-instrumentation creates noise and overhead.

**Correlating traces with logs:**
Include the OTel `traceId` in MDC so log aggregators and trace viewers cross-reference.

---

## Metrics

**Expose metrics endpoint** — Prometheus format is the standard:
```properties
# Endpoint at /metrics or /actuator/prometheus
micrometer.export.prometheus.enabled=true
```

**Custom application metrics:**
```java
// Counter
Counter.builder("myapp.orders.processed")
    .description("Total orders processed")
    .tag("status", "success")
    .register(registry)
    .increment();

// Histogram (measures latency)
Timer.builder("myapp.order.duration")
    .register(registry)
    .record(duration, TimeUnit.MILLISECONDS);
```

**Naming conventions:**
- `service_operation_unit` — e.g., `myapp_orders_total`, `myapp_request_duration_seconds`
- Low-cardinality labels only — never use unique IDs as label values (metrics explosion)

---

## Production Checklist

**Logging:**
- ✅ Structured JSON output enabled for production
- ✅ Plain text for dev/test
- ✅ Log level set to INFO globally
- ✅ Correlation ID in MDC at all entry points
- ✅ Sensitive data exclusion verified

**Tracing:**
- ✅ OTel exporter configured with collector endpoint
- ✅ Service name set
- ✅ Custom spans on business operations
- ✅ Header propagation active for downstream calls
- ✅ Disabled in dev/test (no collector)

**Metrics:**
- ✅ Metrics endpoint exposed
- ✅ Business metrics instrumented (request rate, error rate, key durations)
- ✅ Naming follows `service_operation_unit` convention
- ✅ No high-cardinality labels

---

## Common Pitfalls

| Mistake | Why It's Wrong | Fix |
|---------|----------------|-----|
| Missing correlation IDs | Can't trace requests across services | MDC at all entry points; propagate via headers |
| Unstructured logs in production | Aggregators can't parse or filter | Enable JSON format |
| DEBUG globally in production | Log volume explosion | INFO default; DEBUG per-package only when investigating |
| Logging sensitive data | Security/privacy violation | Never log passwords, PII, tokens |
| Over-instrumented traces | Performance overhead, noise | Instrument significant operations only |
| High-cardinality metric labels | Metrics explosion | Use status codes, operation types — not unique IDs |
| OTel disabled in production | No distributed tracing | Enable; configure sampling if volume is a concern |
| Header propagation missing | Correlation lost at service boundary | Auto-propagate via HTTP client interceptors |
