# Design Document: AI CMF Recommendation Based on New Rules

**Document Version:** 1.0  
**Date:** September 16, 2026  
**Status:** Draft  
**Owner:** Development Team  
**Reviewers:** Mentor, Architecture Review Board

---

## 1. Executive Summary

This design document outlines the implementation of an **AI-driven CMF Recommendation system** for the CMF Portal's Pending List tab. The system analyzes CMF pending sightings using a structured rule-based engine to generate intelligent recommendations (CMF_OK, CMF_REVIEW, CMF_INCOMPLETE, CMF_REJECT) with explainable reasoning and evidence-based scoring.

The feature enables reviewers to make faster, consistent, and evidence-driven decisions on CMF tagging by providing:
- Rule-based recommendation scoring
- Weighted evidence assessment using S/O/D/R/B (Severity, Occurrence, Detection, Recovery, Business) criteria
- Explainable reasoning and missing information identification
- Reviewer actions and next steps

**Target Release:** Phase 2 (post-Quality Assessment)

---

## 2. Objectives

### 2.1 Primary Objectives

1. **Accelerate CMF decision-making** by providing AI-generated recommendations within seconds
2. **Improve consistency** across reviewers by standardizing evaluation criteria
3. **Reduce cognitive load** on reviewers by automating evidence extraction and analysis
4. **Increase transparency** through explainable AI output and scoring breakdown
5. **Support data-driven decisions** by showing which evidence supports or opposes CMF tagging

### 2.2 Secondary Objectives

1. Enable feedback loops to continuously improve recommendation accuracy
2. Identify missing critical information early in the review cycle
3. Support audit trails for compliance and decision traceability
4. Provide actionable guidance for sighting owners on how to improve CMF qualification

---

## 3. Scope

### 3.1 In Scope

- **Recommendation Engine:**
  - Rule-based CMF recommendation using S/O/D/R/B scoring criteria
  - Weighted score calculation (0-5 scale per rule, aggregate 0-100%)
  - Four recommendation outcomes: CMF_OK, CMF_REVIEW, CMF_INCOMPLETE, CMF_REJECT

- **User Interface:**
  - Per-row "AI Recommendation" action button in CMF Pending List
  - Recommendation status badge (CMF_OK, CMF_REVIEW, etc.)
  - Detailed drawer/modal showing full recommendation explanation
  - Evidence breakdown by S/O/D/R/B dimension
  - Missing information list
  - Reviewer action guidance

- **Backend Service:**
  - RESTful endpoint: `CMF_Web_portal.aspx/GetCmfPendingRecommendation`
  - Rule evaluation logic
  - Score aggregation
  - Confidence calculation
  - Audit logging

- **Data Integration:**
  - Consume sighting data: title, component, impact, reproducibility, logs, owner, iDST, etc.
  - Support platform-specific rules if applicable
  - Store recommendation result and timestamp

### 3.2 Out of Scope

- Machine learning or neural network models (Phase 3+ consideration)
- Automatic CMF tagging approval workflow
- Integration with HSD ticket system
- Custom rule builder UI (rules are code-configured)
- Recommendation scheduling or batch processing
- Real-time recommendation streaming

---

## 4. Architecture Overview

### 4.1 High-Level Flow

```
User clicks "AI Recommendation" on CMF Pending row
     ↓
Frontend gathers sighting data (title, impact, logs, etc.)
     ↓
Frontend sends payload to backend endpoint
     ↓
Backend Rule Engine evaluates S/O/D/R/B criteria
     ↓
Backend calculates weighted score (0-100%)
     ↓
Backend maps score to recommendation (CMF_OK, REVIEW, etc.)
     ↓
Backend generates explanation and missing info list
     ↓
Backend returns structured JSON response
     ↓
Frontend renders recommendation drawer with full explanation
     ↓
User reviews recommendation, provides feedback, or updates sighting
```

### 4.2 System Components

#### 4.2.1 Frontend Layer

| Component | Purpose |
|---|---|
| **CMF Pending List View** | Display recommendation status badge per row |
| **AI Recommendation Button** | Trigger recommendation generation |
| **Recommendation Drawer** | Display full recommendation with reasoning |
| **Copy/Share Button** | Export recommendation text |
| **Regenerate Button** | Rerun recommendation after data update |
| **Feedback Buttons** | User-provided feedback (useful/not useful/incorrect) |

#### 4.2.2 Backend Service Layer

| Component | Purpose |
|---|---|
| **Recommendation Endpoint** | Accept sighting payload, return recommendation |
| **Rule Evaluation Engine** | Execute S/O/D/R/B scoring logic |
| **Evidence Extractor** | Parse sighting fields for rule evaluation |
| **Score Aggregator** | Combine dimension scores into final recommendation |
| **Reasoning Generator** | Build human-readable explanation |
| **Missing Info Analyzer** | Identify gaps in sighting data |
| **Audit Logger** | Record inputs, outputs, timestamps, feedback |

#### 4.2.3 Data Layer

| Entity | Purpose |
|---|---|
| **CMF Recommendation Rules** | S/O/D/R/B scoring definitions |
| **Audit Trail** | Log recommendation requests, outputs, feedback |

### 4.3 Data Flow Diagram

```
CMF Pending Sighting Data
  ├─ Title / Problem Description
  ├─ Component
  ├─ Impact (severity, customer scope)
  ├─ Reproducibility (%, ease, frequency)
  ├─ Logs / Sysdebug (presence, quality)
  ├─ Platform / System
  ├─ Owner Assignment
  ├─ iDST Link
  ├─ Workaround / Recovery
  └─ Business / Milestone Impact
           ↓
   [Rule Evaluation Engine]
           ↓
    S Score (Severity): 0-5
    O Score (Occurrence): 0-5
    D Score (Detection): 0-5
    R Score (Recovery): 0-5
    B Score (Business): 0-5
           ↓
   [Aggregation: Weighted Average]
           ↓
    Overall Score (0-100%)
           ↓
   [Decision Mapping]
           ↓
    Recommendation: CMF_OK / REVIEW / INCOMPLETE / REJECT
           ↓
   [Explanation Generator]
           ↓
    Reasoning + Missing Info + Action Items
```

---

## 5. Implementation Overview & Subtask Breakdown

This section provides a clear breakdown of **WHAT** will be built, **HOW** it will be built, and **WHAT** the expected outcomes are for each major subtask.

### 5.0.1 Subtask 1: Determine Scoring Criteria

| Aspect | Details |
|---|---|
| **WHAT** | Define the five evaluation dimensions (Severity, Occurrence, Detection, Recovery, Business) and establish scoring rules for each (1-5 scale). |
| **HOW** | <ul><li>Research historical CMF decisions and patterns</li><li>Interview CMF review board members to understand decision criteria</li><li>Document scoring thresholds and evidence signals for each dimension</li><li>Create scoring lookup tables and decision trees</li><li>Validate scoring logic against 20+ historical CMF cases</li></ul> |
| **EXPECTED OUTCOME** | <ul><li>5 scoring rubrics (S/O/D/R/B) with clear, measurable criteria</li><li>Evidence signals documented for each score level (1-5)</li><li>Scoring logic validated and approved by CMF review board</li><li>Decision matrix showing score→recommendation mapping</li></ul> |
| **Effort** | 16-20 hours (research + documentation + validation) |
| **Success Criteria** | CMF review board consensus (≥80% agreement) on scoring fairness and completeness |

### 5.0.2 Subtask 2: Update Backend Service for Rule-Based Recommendation

| Aspect | Details |
|---|---|
| **WHAT** | Build the backend recommendation engine that evaluates scoring criteria, calculates weighted scores, and generates recommendations with reasoning. |
| **HOW** | <ul><li>Create `CMFRecommendationEngine` class in App_Code/CmfRecommendationService.cs</li><li>Implement 5 rule evaluators: SeverityRule, OccurrenceRule, DetectionRule, RecoveryRule, BusinessRule</li><li>Build score aggregation logic using weighted formula</li><li>Implement recommendation mapping (score → CMF_OK/REVIEW/INCOMPLETE/REJECT)</li><li>Add input validation to check required fields</li><li>Unit test each rule and aggregation logic</li></ul> |
| **EXPECTED OUTCOME** | <ul><li>Fully functional rule engine that scores 5 dimensions independently</li><li>Weighted score calculation (0-5 scale)</li><li>Reliable recommendation mapping with clear thresholds</li><li>Error handling for missing/invalid input data</li><li>Unit test coverage >90%</li></ul> |
| **Effort** | 24-28 hours (coding + testing + refinement) |
| **Success Criteria** | <ul><li>All rule evaluators pass unit tests</li><li>Score aggregation tested with 50+ test cases</li><li>Backend can process 10+ recommendations/second</li></ul> |

### 5.0.3 Subtask 3: Return Structured Response from Backend

| Aspect | Details |
|---|---|
| **WHAT** | Design and implement a structured JSON response containing the recommendation, rule scores, reasoning, evidence analysis, and missing information. |
| **HOW** | <ul><li>Define response contract (DTO) with all required fields</li><li>Implement `CMFRecommendationResponse` class with nested objects for rule scores</li><li>Build reasoning generator that converts rule evaluations into human-readable text</li><li>Implement evidence extractor that identifies and ranks supporting signals</li><li>Create missing information analyzer that flags gaps</li><li>Serialize response to JSON for frontend consumption</li></ul> |
| **EXPECTED OUTCOME** | <ul><li>Structured JSON response with all recommendation details</li><li>Response includes: Recommendation, Overall Score, Rule Scores, Reasoning, Missing Info, Reviewer Actions</li><li>Human-readable reasoning text (not just raw scores)</li><li>Evidence organized by relevance and confidence</li><li>Response serialization tested and validated</li></ul> |
| **Effort** | 12-16 hours (design + coding + serialization testing) |
| **Success Criteria** | <ul><li>Response schema approved by stakeholders</li><li>JSON response passes schema validation</li><li>Response time <3 seconds for typical sighting</li><li>All required fields populated in all scenarios</li></ul> |

### 5.0.4 Subtask 4: Add Guardrails for Missing Critical Information

| Aspect | Details |
|---|---|
| **WHAT** | Implement safety mechanisms to prevent recommending CMF_OK when critical information is missing, ensuring the AI does not give false confidence. |
| **HOW** | <ul><li>Define "critical information" checklist: severity, reproducibility, customer impact, logs</li><li>Implement pre-evaluation validation that checks critical field presence</li><li>If critical info missing: set recommendation to CMF_INCOMPLETE regardless of scores</li><li>Add confidence level assessment (High/Medium/Low based on data completeness)</li><li>Flag missing fields explicitly in response with required actions</li><li>Test guardrails with incomplete sighting data</li></ul> |
| **EXPECTED OUTCOME** | <ul><li>Guardrails prevent CMF_OK when >1 critical field is missing</li><li>CMF_INCOMPLETE status returned with clear guidance on what to collect</li><li>Confidence level accurately reflects data completeness</li><li>Response includes prioritized list of missing information</li><li>No false positives (CMF_OK recommendations when data is insufficient)</li></ul> |
| **Effort** | 8-12 hours (guardrail logic + validation testing) |
| **Success Criteria** | <ul><li>100% of incomplete sightings correctly route to CMF_INCOMPLETE (not OK)</li><li>Confidence level correlates with data completeness</li><li>Feedback from reviewers: guardrails are effective and not over-cautious</li></ul> |

### 5.0.5 Subtask 5: Enable Recommendation Updates After Data Changes

| Aspect | Details |
|---|---|
| **WHAT** | Provide ability to regenerate and update recommendations when sighting data is modified, ensuring recommendations stay current. |
| **HOW** | <ul><li>Implement "Regenerate" button in recommendation drawer UI</li><li>On data change: invalidate cached recommendation</li><li>Re-run recommendation engine with latest sighting data</li><li>Compare new score against previous score</li><li>Show change summary: "Score improved from 2.5 to 3.8"</li><li>Maintain history of previous recommendations</li><li>Update audit trail with regeneration event</li></ul> |
| **EXPECTED OUTCOME** | <ul><li>Users can regenerate recommendations after data updates</li><li>UI shows regeneration in progress and new result</li><li>Recommendation cache is invalidated on data change</li><li>History maintained showing previous recommendations</li><li>Audit trail captures regeneration timestamp and score change</li></ul> |
| **Effort** | 10-14 hours (UI + caching logic + history tracking) |
| **Success Criteria** | <ul><li>Regenerate button works reliably</li><li>New recommendation reflects latest data</li><li>Previous recommendations remain visible in history</li><li>Audit trail is complete and queryable</li></ul> |

### 5.0.6 Subtask 6: Add Logging for Audit and Debugging

| Aspect | Details |
|---|---|
| **WHAT** | Implement comprehensive logging of all recommendation requests, scoring evaluations, and outputs for audit compliance, troubleshooting, and continuous improvement. |
| **HOW** | <ul><li>Create `RecommendationAuditLogger` class</li><li>Log at key points: <ul><li>Request received (sighting ID, user, timestamp)</li><li>Rule evaluation input/output for each dimension</li><li>Score aggregation calculation</li><li>Final recommendation and confidence</li><li>Any guardrail triggers or validation failures</li><li>Response sent (timestamp, user action if tracked)</li></ul></li><li>Store logs in database table: `CMF_Recommendation_Audit`</li><li>Include context: platform, component, owner</li><li>Support log querying/reporting for debugging</li></ul> |
| **EXPECTED OUTCOME** | <ul><li>Complete audit trail of all recommendations</li><li>Each log entry includes: timestamp, sighting ID, user, input data, scores, output recommendation</li><li>Audit database queryable for compliance reports</li><li>Logs enable root cause analysis for incorrect recommendations</li><li>Performance impact <100ms per recommendation</li><li>Audit logs retained for 12+ months</li></ul> |
| **Effort** | 12-16 hours (logging infrastructure + database + querying) |
| **Success Criteria** | <ul><li>100% of recommendations logged with full context</li><li>Audit table has <5ms query time for typical audit reports</li><li>Log retention policy defined and enforced</li><li>No sensitive data (PII) in logs</li></ul> |

### 5.0.7 Subtask 7: Validate Recommendations Against Sample Sightings

| Aspect | Details |
|---|---|
| **WHAT** | Test recommendation engine against real-world CMF pending sightings to verify accuracy, identify scoring edge cases, and refine rule thresholds. |
| **HOW** | <ul><li>Curate 20-30 representative CMF sightings with known dispositions</li><li>Run recommendation engine against each sample</li><li>Compare AI recommendation vs. actual reviewer decision</li><li>Calculate accuracy metrics: true positive, false positive, false negative rates</li><li>Identify discrepancies and analyze root cause</li><li>Refine rule thresholds or weighting if needed</li><li>Re-test until accuracy meets target (>75%)</li><li>Document validation results and edge cases</li></ul> |
| **EXPECTED OUTCOME** | <ul><li>Validation dataset of 20-30 representative sightings with labels</li><li>Accuracy report: % correct recommendations by category</li><li>Confusion matrix showing recommendation errors</li><li>Edge cases documented with rule refinements</li><li>False positive / false negative rates <10% each</li><li>Scoring thresholds validated and potentially adjusted</li><li>Recommendations ready for pilot/rollout</li></ul> |
| **Effort** | 16-20 hours (data curation + testing + analysis + refinement) |
| **Success Criteria** | <ul><li>≥75% of sample recommendations match actual reviewer decisions</li><li>False positives (CMF_OK should be REJECT): <10%</li><li>False negatives (CMF_REJECT should be OK): <10%</li><li>Mentor/review board approves validation results</li></ul> |

---

### 5.0.8 Subtasks Summary Table

| # | Subtask | WHAT (Goal) | HOW (Approach) | OUTCOME (Deliverable) | Effort | Success Criteria |
|---|---|---|---|---|---|---|
| 1 | Determine Scoring Criteria | Define S/O/D/R/B scoring rules | Research + interview + validation | 5 rubrics + evidence signals + board approval | 16-20h | ≥80% board consensus |
| 2 | Update Backend Service | Build rule-based recommendation engine | Create evaluators + aggregation + testing | Working engine with unit tests | 24-28h | >90% test coverage, 10+ rec/sec |
| 3 | Return Structured Response | Design JSON response schema | Implement DTO + reasoning generator | Structured JSON with all fields | 12-16h | Response validated, <3s latency |
| 4 | Add Guardrails | Prevent false CMF_OK recommendations | Validation logic + confidence assessment | Safe recommendations + clear guidance | 8-12h | 100% incomplete→CMF_INCOMPLETE |
| 5 | Enable Recommendation Updates | Support regeneration after data changes | UI button + caching logic + history | Regenerate capability + audit trail | 10-14h | Reliable regeneration + history |
| 6 | Add Logging for Audit | Complete audit trail of all recommendations | Create audit logger + database + queries | Full audit trail queryable | 12-16h | 100% logged, <5ms query time |
| 7 | Validate Recommendations | Test accuracy against real sightings | Curate samples + test + analyze + refine | Validation report + >75% accuracy | 16-20h | ≥75% accuracy + board approval |

---

## 6. Functional Requirements

### 6.1 Rule Definitions and Scoring

#### 5.1.1 Severity (S) Rule

**Definition:** Evaluate the customer-visible impact and severity of the failure.

**Scoring Criteria:**

| Score | Condition |
|---|---|
| **5 (Excellent)** | Must fix / blocker; platform-wide failure; data loss; customer operations blocked |
| **4 (Good)** | Significant impact; workaround exists but expensive; multiple customers affected |
| **3 (Fair)** | Moderate impact; annoying to customer; limited scope or single customer |
| **2 (Poor)** | Minor impact; cosmetic or edge case; rarely encountered |
| **1 (Minimal)** | Severity unclear, missing or vague symptom description |

**Evidence Signals:**
- Error code / crash type in logs
- Issue title keywords (crash, hang, loss, data)
- Explicit impact statement
- Number of affected customers

---

#### 5.1.2 Occurrence (O) Rule

**Definition:** Evaluate how frequently the failure reproduces and probability of customer hit.

**Scoring Criteria:**

| Score | Condition |
|---|---|
| **5 (Excellent)** | 100% reproducible; frequent occurrence; high probability every customer hits |
| **4 (Good)** | >50% reproducible; regular occurrence; many customers likely affected |
| **3 (Fair)** | 20-50% reproducible; intermittent; reasonable probability of customer hit |
| **2 (Poor)** | <20% reproducible; rare; unlikely unless specific scenario |
| **1 (Minimal)** | Reproducibility unknown or not described |

**Evidence Signals:**
- Explicit reproducibility percentage
- Frequency count (daily, weekly, etc.)
- Repro steps availability
- Repro on RVP platform
- Customer sighting frequency

---

#### 5.1.3 Detection (D) Rule

**Definition:** Evaluate visibility of the issue—how easily customers can detect / encounter it.

**Scoring Criteria:**

| Score | Condition |
|---|---|
| **5 (Excellent)** | Customer immediately encounters; always visible during common operation |
| **4 (Good)** | Customer will encounter during typical workflow |
| **3 (Fair)** | Customer may encounter in certain scenarios; hidden unless specific usage path |
| **2 (Poor)** | Customer unlikely to trigger unless doing unusual things |
| **1 (Minimal)** | Customer detection scenario unclear or not described |

**Evidence Signals:**
- Usage trigger / customer scenario description
- Platform scope (all users vs. specific setup)
- Operation type (install, boot, runtime, stress test)
- Environmental dependency

---

#### 5.1.4 Recovery (R) Rule

**Definition:** Evaluate available workarounds or recovery options for the customer.

**Scoring Criteria:**

| Score | Condition |
|---|---|
| **5 (Excellent)** | No workaround; customer cannot recover independently |
| **4 (Good)** | Workaround requires escalation or data recovery; time-consuming |
| **3 (Fair)** | Workaround exists; customer can self-recover or retry |
| **2 (Poor)** | Easy workaround or auto-recovery; customer impact is low |
| **1 (Minimal)** | Recovery status unknown or not described |

**Evidence Signals:**
- Explicit workaround statement
- Recovery procedure availability
- Time-to-recovery estimate
- Whether workaround is self-service

---

#### 5.1.5 Business (B) Rule

**Definition:** Evaluate milestone, launch, escalation, or business exposure impact.

**Scoring Criteria:**

| Score | Condition |
|---|---|
| **5 (Excellent)** | Blocks launch gate / validation / customer commitment; high financial impact |
| **4 (Good)** | Affects key milestone; escalation required; business risk |
| **3 (Fair)** | Affects roadmap or performance; moderate business exposure |
| **2 (Poor)** | Low business exposure; nice-to-fix but not blocking |
| **1 (Minimal)** | Business/milestone impact unknown or not stated |

**Evidence Signals:**
- Milestone / WW / gating gate linkage
- Launch blocker designation
- Customer escalation level
- Financial or warranty impact
- Validation gate blocking

---

### 5.2 Score Aggregation and Recommendation Mapping

#### 5.2.1 Weighted Score Calculation

```
Overall Score = (S_score × 0.25) + (O_score × 0.25) + (D_score × 0.20) + 
                (R_score × 0.15) + (B_score × 0.15)

Result: 0-5 scale (or 0-100%)
```

**Weighting Rationale:**
- Severity (25%): Foundation—if not severe, CMF justification is weak
- Occurrence (25%): Frequency drives customer risk
- Detection (20%): How many customers will hit this?
- Recovery (15%): Workaround availability reduces urgency
- Business (15%): Milestone/launch impact is a decision factor

#### 5.2.2 Recommendation Thresholds

| Score Range | Recommendation | Meaning |
|---|---|---|
| **≥4.0** | **CMF_OK** | Strong CMF qualification; approve with confidence |
| **3.0–3.9** | **CMF_REVIEW** | Near threshold; reviewer judgment needed; may approve if conditions met |
| **2.0–2.9** | **CMF_INCOMPLETE** | Evidence not sufficient for decision; ask for more data |
| **<2.0** | **CMF_REJECT** | Below CMF threshold; do not tag unless evidence is missing |

---

### 5.3 Output Structure

#### 5.3.1 Recommendation Response JSON

```json
{
  "Success": true,
  "Recommendation": "CMF_OK",
  "OverallScore": 4.2,
  "Confidence": "High",
  "Summary": "Strong CMF qualification based on...",
  "RuleScores": [
    {
      "RuleId": "S",
      "RuleName": "Severity",
      "Score": 5,
      "Evaluation": "Platform-wide failure blocking customer operations."
    },
    {
      "RuleId": "O",
      "RuleName": "Occurrence",
      "Score": 4,
      "Evaluation": "Regularly occurs; multiple customers affected weekly."
    },
    {
      "RuleId": "D",
      "RuleName": "Detection",
      "Score": 4,
      "Evaluation": "Customers will encounter during standard boot/init workflow."
    },
    {
      "RuleId": "R",
      "RuleName": "Recovery",
      "Score": 3,
      "Evaluation": "Workaround requires reflash; time-consuming for customer."
    },
    {
      "RuleId": "B",
      "RuleName": "Business",
      "Score": 4,
      "Evaluation": "Affects WW validation gate; escalation in progress."
    }
  ],
  "Evidence": {
    "Strengths": [
      "Clear symptom description with crash codes.",
      "100% reproducible on RVP platform.",
      "Affects high-priority customer.",
      "Blocks launch validation gate."
    ],
    "Gaps": [
      "Exact reproduction steps not documented.",
      "No workaround timeline provided."
    ],
    "ImpactSentence": "Failure blocks customer operations and WW validation; must fix.",
    "RecommendationReasoning": [
      "Strong evidence across Severity, Occurrence, and Business impact.",
      "Detection is clear; user will hit this during initialization.",
      "Recovery workaround is acceptable but expensive.",
      "Score of 4.2/5 supports CMF_OK recommendation."
    ]
  },
  "MissingInformation": [
    "Exact reproduction steps would improve Occurrence confidence.",
    "Workaround timeline and cost to customer needed.",
    "Validation gate name and target date should be explicit."
  ],
  "ReviewerActions": [
    "Confirm the high S/O/D/R/B evidence and approve CMF tagging.",
    "Verify WW gate is actually blocked by this issue.",
    "Ensure escalation and customer communication are in progress.",
    "Set fix target date and link to implementation plan."
  ],
  "Timestamp": "2026-09-16T14:32:00Z",
  "Platform": "PTL"
}
```

---

## 7. Non-Functional Requirements

### 7.1 Performance

| Requirement | Target | Rationale |
|---|---|---|
| Recommendation generation time | <5 seconds | User should see result quickly without long wait |
| API response time (p95) | <3 seconds | Portal responsiveness expectation |
| Concurrent recommendations | 10+ simultaneous | Support multiple reviewers working at same time |
| Recommendation cache TTL | 30 minutes | Reasonable freshness; avoid recomputing identical sightings |

### 7.2 Reliability

| Requirement | Target |
|---|---|
| Availability | 99.5% uptime during business hours |
| Graceful degradation | Show cached or previous recommendation if service fails |
| Error handling | Clear error message; allow retry or manual review fallback |
| Data integrity | Never recommend on incomplete data; flag missing info explicitly |

### 7.3 Security & Compliance

| Requirement | Implementation |
|---|---|
| Access control | Only assigned reviewers can request recommendations for their platform |
| Audit logging | Log all recommendation requests, outputs, user feedback |
| Data retention | Keep audit trail for 12 months minimum |
| PII masking | Don't expose customer names or sensitive data in reasoning |

### 7.4 Usability

| Requirement | Implementation |
|---|---|
| Explainability | Every recommendation includes clear reasoning and evidence list |
| Accessibility | Recommendation text supports screen readers; use semantic HTML |
| Mobile support | Drawer/modal responsive on tablets and mobile devices |
| Offline fallback | Show cached recommendation if network fails |

---

## 8. Detailed Implementation Plan

### 8.1 Phase 2A: Core Rule Engine (Week 1-2)

**Deliverables:**
- Rule evaluation service (backend C#)
- S/O/D/R/B score calculation logic
- Recommendation mapping
- Unit tests for each rule

**Tasks:**
1. Create `CMFRecommendationEngine` class
2. Implement S/O/D/R/B rule evaluators (5 methods)
3. Implement score aggregation and thresholds
4. Add rule evaluation tests
5. Create mock data for testing

**Estimated Effort:** 16 hours

---

### 8.2 Phase 2B: Backend Endpoint (Week 2-3)

**Deliverables:**
- RESTful endpoint `GetCmfPendingRecommendation`
- Input validation
- Response serialization
- Audit logging
- Error handling

**Tasks:**
1. Create Web API endpoint in `CMF_Web_portal.aspx.cs`
2. Implement request/response contracts
3. Add logging to recommendation service (App_Code)
4. Implement error handling and fallbacks
5. Add integration tests

**Estimated Effort:** 12 hours

---

### 8.3 Phase 2C: Frontend UI - Row Badge (Week 3)

**Deliverables:**
- Recommendation status badge in CMF Pending List
- Quick visual status (color-coded)
- Tooltip showing score

**Tasks:**
1. Add badge column to GridView_cmf_pending
2. Bind recommendation status from server
3. Style badges (green/yellow/orange/red)
4. Add ARIA labels for accessibility
5. Test with multiple recommendation states

**Estimated Effort:** 8 hours

---

### 8.4 Phase 2D: Frontend UI - Drawer & Details (Week 3-4)

**Deliverables:**
- Recommendation drawer/modal
- Rule score breakdown display
- Evidence and reasoning sections
- Missing information list
- Reviewer action guidance

**Tasks:**
1. Create drawer HTML structure (use existing modal pattern from AI Summary)
2. Implement rule score cards (S/O/D/R/B display)
3. Build evidence section renderer
4. Display missing information list
5. Add reviewer actions section
6. Style and test responsiveness

**Estimated Effort:** 16 hours

---

### 8.5 Phase 2E: Frontend Interaction (Week 4)

**Deliverables:**
- "AI Recommendation" button functionality
- Trigger endpoint call with sighting data
- Loading state during fetch
- Copy recommendation to clipboard
- Regenerate button
- Feedback buttons (useful/not useful)

**Tasks:**
1. Add event listener to recommendation button
2. Gather sighting data from row
3. Call backend endpoint
4. Handle loading/error states
5. Populate drawer with response
6. Add copy and regenerate buttons
7. Add feedback mechanism

**Estimated Effort:** 12 hours

---

### 8.6 Phase 2F: Testing & Refinement (Week 4-5)

**Deliverables:**
- Unit tests (rules, scoring, mapping)
- Integration tests (endpoint, serialization)
- Manual QA checklist
- Performance testing
- Edge case handling

**Tasks:**
1. Run rule evaluation tests with various inputs
2. Test with incomplete/missing data
3. Test performance at scale
4. Verify audit logging
5. Test error scenarios (service down, timeout)
6. Accessibility testing
7. Cross-browser testing

**Estimated Effort:** 12 hours

---

### 8.7 Timeline Summary

| Phase | Duration | Key Output |
|---|---|---|
| 2A: Rule Engine | 2 weeks | Scoring logic, tests |
| 2B: Backend Endpoint | 2 weeks | API, logging, error handling |
| 2C: Row Badge | 1 week | Visual status in list |
| 2D: Drawer UI | 2 weeks | Full recommendation explanation |
| 2E: Interaction | 1 week | Button clicks, regenerate, feedback |
| 2F: Testing | 2 weeks | QA, performance, edge cases |
| **Total Phase 2** | **~10 weeks** | **Production-ready AI Recommendation** |

---

## 9. Data Requirements

### 9.1 Input Data (from CMF Pending Sighting)

The recommendation engine requires:

| Field | Source | Required | Example |
|---|---|---|---|
| Issue Title | CMF request | Yes | "System hangs on resume from S3" |
| Component | CMF row | Yes | "FIRMWARE" |
| Customer Impact | CMF request detail | Yes | "Blocks customer daily workflow" |
| Reproducibility | CMF row | Recommended | "100% on RVP test" |
| Severity Level | CMF row / Assessment | Recommended | "Must fix" |
| Platform | Dropdown or CMF data | Yes | "PTL" |
| Owner | CMF row | Recommended | "john.doe@intel.com" |
| iDST Link | CMF row | Recommended | "HSD-12345" |
| Logs / Sysdebug | Artifact metadata | Recommended | "Present, 5MB" |
| Workaround | CMF request detail | Recommended | "Requires reflash (~30 min)" |
| Milestone / Gate | CMF request detail | Recommended | "WW50 validation gate" |
| Customer Escalation | CMF request detail | Recommended | "VP-level" |

### 9.2 Output Data

The recommendation engine produces:

| Field | Type | Example |
|---|---|---|
| Recommendation | Enum | "CMF_OK" |
| Overall Score | Decimal (0-5) | 4.2 |
| Rule Scores | Object[] | [{ RuleId: "S", Score: 5 }, ...] |
| Confidence | String | "High" |
| Reasoning | String[] | ["Severity is critical", "..."] |
| Missing Info | String[] | ["Exact reproduction steps", "..."] |
| Reviewer Actions | String[] | ["Confirm escalation", "..."] |
| Timestamp | DateTime | "2026-09-16T14:32:00Z" |

---

## 10. Testing Strategy

### 10.1 Unit Tests

**Rule Evaluators:**
- Test each rule (S/O/D/R/B) with valid, edge-case, and invalid inputs
- Verify score output is between 1-5
- Test empty or null data handling

**Score Aggregation:**
- Test weighted average calculation
- Verify result is between 0-5
- Test recommendation mapping logic

**Example Test Case:**

```csharp
[TestMethod]
public void EvaluateSeverityRule_CriticalIssue_Returns5()
{
    // Arrange
    var sighting = new CMFSighting 
    { 
        Title = "System crash on boot",
        Impact = "Must fix - blocks all customers"
    };
    var rule = new SeverityRule();
    
    // Act
    var score = rule.Evaluate(sighting);
    
    // Assert
    Assert.AreEqual(5, score);
}
```

### 9.2 Integration Tests

- Test full endpoint request/response flow
- Test with real CMF pending sighting data
- Verify audit logging is recorded
- Test error scenarios (missing fields, service unavailable)

### 9.3 Manual QA Checklist

- [ ] Recommendation button appears for each CMF Pending row
- [ ] Clicking button opens drawer with recommendation
- [ ] Drawer shows rule scores, reasoning, and missing info
- [ ] Copy button copies recommendation text to clipboard
- [ ] Regenerate button re-runs recommendation
- [ ] Feedback buttons submit feedback to backend
- [ ] Recommendation is cached and reused within 30 minutes
- [ ] Empty/error states display graceful messages
- [ ] Recommendation works across all platforms (PTL, LNL, ARL-S, etc.)
- [ ] Performance is acceptable (<5 seconds)
- [ ] Mobile responsiveness is good
- [ ] Accessibility: screen reader support, keyboard navigation

### 9.4 Sample Test Data

| Scenario | Input | Expected Output |
|---|---|---|
| Strong CMF case | High severity, 100% repro, no workaround, blocks gate | CMF_OK, score ≥4.0 |
| Borderline case | Medium severity, 50% repro, workaround exists | CMF_REVIEW, score 3.0-3.9 |
| Incomplete case | Missing repro rate, missing customer impact | CMF_INCOMPLETE, gaps flagged |
| Reject case | Low severity, rare occurrence, workaround available | CMF_REJECT, score <2.0 |

---

## 11. Success Metrics

### 11.1 Adoption Metrics

| Metric | Target | Measurement |
|---|---|---|
| % of CMF Pending sightings with recommendation generated | >80% | Dashboard counter |
| Avg recommendations per reviewer per day | >10 | Audit log analysis |
| % of recommendations used in final decision | >60% | Reviewer feedback survey |

### 11.2 Quality Metrics

| Metric | Target | Measurement |
|---|---|---|
| Recommendation accuracy (verified against final decision) | >75% | Audit trail analysis |
| User satisfaction (feedback useful/not useful ratio) | >70% useful | Portal feedback system |
| False positive rate (CMF_OK but rejected by reviewer) | <10% | Audit analysis |
| False negative rate (CMF_REJECT but approved by reviewer) | <5% | Audit analysis |

### 11.3 Operational Metrics

| Metric | Target | Measurement |
|---|---|---|
| Avg recommendation generation time | <3 seconds (p95) | Backend logs |
| Recommendation endpoint uptime | 99.5% | Service monitoring |
| Error rate (failed recommendation calls) | <1% | Backend error logs |

---

## 12. Risk Assessment & Mitigation

| Risk | Impact | Probability | Mitigation |
|---|---|---|---|
| **Rule logic is inaccurate** | Recommendations are wrong; reviewers lose trust | Medium | Extensive testing with real CMF data; reviewer feedback loop; rule tuning phase |
| **Missing data causes poor recommendations** | Score is skewed; decision is unreliable | High | Explicitly flag missing info; use CMF_INCOMPLETE status; don't recommend without critical data |
| **Performance degrades with scale** | Endpoint times out; users frustrated | Low | Implement caching; load test before release; add fallback to cached result |
| **User expects automated approval** | Over-reliance on AI; incorrect approvals | Medium | Clear labeling: "AI Recommendation" not "Auto Approval"; require manual reviewer sign-off |
| **Audit trail is incomplete** | Compliance risk; no traceability | Low | Log all inputs, outputs, user feedback; verify logging in integration tests |

---

## 13. Dependencies & Prerequisites

### 13.1 Technical Dependencies

- Existing CMF Portal infrastructure (App_Code services, ASPX controls)
- Access to CMF Pending sighting data schema
- Backend service capability (C# Web API)
- Frontend rendering libraries (existing: marked.js, DOMPurify)

### 13.2 Data Dependencies

- Complete CMF Pending sighting records with required fields
- Historical CMF decision data (for validation and tuning)
- Platform mappings (PTL, LNL, ARL, etc.)

### 13.3 Organizational Dependencies

- Decision on rule thresholds and weighting (sign-off)
- Approval from CMF Review Board
- Feedback from sample reviewers (early QA)

---

## 14. Assumptions

1. **Rule-based scoring is sufficient** for Phase 2; ML-based recommendation can be Phase 3+
2. **Sighting data quality is adequate** to evaluate most rules; missing data is handled gracefully
3. **Reviewer will not blindly approve recommendations** without reading reasoning
4. **Platform-specific rules can be hardcoded** rather than dynamically configured
5. **Recommendation cache (30-min TTL) is acceptable** for most use cases
6. **Audit logging overhead is acceptable** for performance SLA

---

## 15. Future Enhancements (Phase 3+)

### 15.1 Short-term Enhancements

- **Rule tuning dashboard:** Allow CMF leads to adjust scoring weights
- **A/B testing:** Compare rule-based vs. alternative recommendation approaches
- **Historical accuracy:** Track and visualize recommendation correctness over time
- **Recommendation analytics:** Provide statistics on CMF_OK vs. REVIEW vs. INCOMPLETE distribution

### 15.2 Medium-term Enhancements

- **Machine learning integration:** Use historical CMF decisions to train recommendation model
- **Custom rule builder UI:** Enable reviewers to define platform-specific rules without code
- **Recommendation streaming:** Real-time recommendation updates as sighting data changes
- **Batch recommendation:** Generate recommendations for all pending sightings in one operation

### 15.3 Long-term Vision

- **Predictive blocker detection:** Identify which CMF issues are likely to block validation gates
- **Automated escalation:** Route high-risk or overdue items to appropriate escalation channels
- **Cross-platform pattern detection:** Identify recurring issues across platforms
- **Recommendation feedback loop:** Automatically retrain model based on reviewer decisions

---

## 16. Glossary

| Term | Definition |
|---|---|
| **CMF** | Critical Manufacturing Flaw; issues that must be fixed before launch/validation |
| **CMF_OK** | Recommendation to approve CMF tagging; evidence is strong |
| **CMF_REVIEW** | Recommendation to have reviewer examine manually; evidence is borderline |
| **CMF_INCOMPLETE** | Recommendation to gather more data before decision; insufficient evidence |
| **CMF_REJECT** | Recommendation to not tag as CMF; evidence does not meet threshold |
| **Sighting** | Individual customer or test report of a failure; basis for CMF decision |
| **S/O/D/R/B** | Severity, Occurrence, Detection, Recovery, Business; five evaluation dimensions |
| **Score** | Numeric rating (1-5 per rule, 0-5 aggregate) indicating confidence in a rule dimension |
| **Confidence** | Qualitative confidence level (High/Medium/Low) in the overall recommendation |
| **Audit Trail** | Log of recommendation inputs, outputs, timestamps, and user feedback |

---

## 17. Approval Sign-Off

| Role | Name | Date | Signature |
|---|---|---|---|
| Author | Development Team | Sept 16, 2026 | __ |
| Mentor/Reviewer | [Mentor Name] | | __ |
| Architecture Lead | [Lead Name] | | __ |
| CMF Review Board | [Board Chair] | | __ |

---

**Document Version History**

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.0 | Sept 16, 2026 | Dev Team | Initial design document |
| 1.1 | Sept 16, 2026 | Dev Team | Added Implementation Overview with detailed subtask breakdown (WHAT/HOW/OUTCOME) |
| | | | |

---

**End of Design Document**
