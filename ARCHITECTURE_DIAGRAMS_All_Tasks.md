# Architectural Diagrams: CMF Portal Development Tasks

**Document Version:** 1.0  
**Date:** September 16, 2026  
**Purpose:** Provide visual architectural flows for all 6 development tasks

---

## Table of Contents

1. [AI CMF Recommendation](#1-ai-cmf-recommendation)
2. [Sighting Quality Assessment](#2-sighting-quality-assessment)
3. [Similar Issue Intelligence](#3-similar-issue-intelligence)
4. [AI-Assisted Initial Debug Triage](#4-ai-assisted-initial-debug-triage)
5. [UI Changes](#5-ui-changes)
6. [Aging, Priority and Accountability](#6-aging-priority-and-accountability)

---

## 1. AI CMF Recommendation

### 1.1 Overall System Architecture

```mermaid
graph TB
    subgraph "Frontend Layer"
        A["CMF Pending List View"]
        B["Recommendation Button"]
        C["Recommendation Drawer/Modal"]
        D["Copy & Regenerate Controls"]
    end

    subgraph "API Layer"
        E["GetCmfPendingRecommendation Endpoint"]
        F["Request Validation"]
    end

    subgraph "Backend Processing"
        G["CMFRecommendationEngine"]
        H1["Severity Rule Evaluator"]
        H2["Occurrence Rule Evaluator"]
        H3["Detection Rule Evaluator"]
        H4["Recovery Rule Evaluator"]
        H5["Business Rule Evaluator"]
        I["Score Aggregation & Mapping"]
        J["Guardrail Checker"]
        K["Reasoning Generator"]
        L["Missing Info Analyzer"]
    end

    subgraph "Data & Logging"
        M["CMF Pending Sighting Data"]
        N["Audit Logger"]
        O["Recommendation Cache"]
        P["Audit Trail Database"]
    end

    subgraph "Response"
        Q["Structured JSON Response"]
    end

    A -->|Click Recommendation| B
    B -->|Gather Sighting Data| E
    E --> F
    F -->|Valid| G
    G --> H1 & H2 & H3 & H4 & H5
    H1 & H2 & H3 & H4 & H5 -->|Individual Scores| I
    I --> J
    J -->|Pass| K & L
    K & L --> Q
    Q --> N
    N --> P
    Q -->|Render| C
    C --> D
    M -->|Feed| G
    G -.->|Store/Retrieve| O

    style A fill:#e1f5ff
    style G fill:#fff3e0
    style Q fill:#f3e5f5
    style P fill:#e8f5e9
```

### 1.2 Recommendation Generation Flow

```mermaid
graph TD
    A["User Clicks AI Recommendation Button"] -->|Sighting ID| B["Frontend Gathers Sighting Data"]
    B -->|JSON Payload| C["Backend Endpoint Receives Request"]
    C --> D["Check Cache for Recent Recommendation"]
    D -->|Hit| E["Return Cached Result"]
    D -->|Miss| F["Validate Input Data"]
    
    F -->|Valid| G["Initialize Rule Engine"]
    F -->|Invalid| H["Return Error Response"]
    
    G -->|Severity| S["Evaluate S Rule"]
    G -->|Occurrence| O["Evaluate O Rule"]
    G -->|Detection| D2["Evaluate D Rule"]
    G -->|Recovery| R["Evaluate R Rule"]
    G -->|Business| B2["Evaluate B Rule"]
    
    S & O & D2 & R & B2 -->|Scores 1-5| I["Aggregate Scores: Weighted Average"]
    I -->|Score 0-5| J["Map to Recommendation"]
    
    J -->|Check| K["Apply Guardrails"]
    K -->|Critical Info Missing| L["Set CMF_INCOMPLETE"]
    K -->|Pass| M["Keep Mapped Recommendation"]
    
    L & M -->|Final Recommendation| N["Generate Reasoning & Missing Info"]
    N -->|Structured Output| O2["Build JSON Response"]
    
    O2 -->|Log| P["Audit Logger: Record All Details"]
    P --> Q["Cache Result for 30 mins"]
    Q -->|Response| R2["Send to Frontend"]
    
    E -->|Response| R2
    H -->|Response| R2
    R2 -->|Render| R3["Display Recommendation Drawer"]
    
    R3 -->|User Actions| R4["Copy / Regenerate / Feedback"]

    style A fill:#e3f2fd
    style R3 fill:#f3e5f5
    style L fill:#ffebee
    style M fill:#e8f5e9
```

### 1.3 Score Calculation Engine

```mermaid
graph LR
    subgraph "Severity Rule"
        S1["Extract from: Title, Impact, Keywords"]
        S2["Match: Must-fix, Platform-wide, Data loss?"]
        S3["Score: 1-5"]
    end

    subgraph "Occurrence Rule"
        O1["Extract from: Reproducibility %, Frequency"]
        O2["Match: 100%, >50%, 20-50%, <20%"]
        O3["Score: 1-5"]
    end

    subgraph "Detection Rule"
        D1["Extract from: Usage Trigger, Customer Scenario"]
        D2["Match: Common op, Typical workflow, Specific scenario"]
        D3["Score: 1-5"]
    end

    subgraph "Recovery Rule"
        R1["Extract from: Workaround, Recovery Status"]
        R2["Match: None, Escalation needed, Self-recover"]
        R3["Score: 1-5"]
    end

    subgraph "Business Rule"
        B1["Extract from: Milestone, Launch Gate, Escalation"]
        B2["Match: Blocks gate, Affects milestone, Nice-to-fix"]
        B3["Score: 1-5"]
    end

    subgraph "Aggregation"
        A1["S_score × 0.25"]
        A2["O_score × 0.25"]
        A3["D_score × 0.20"]
        A4["R_score × 0.15"]
        A5["B_score × 0.15"]
        A6["Sum = Overall Score 0-5"]
    end

    S3 --> A1
    O3 --> A2
    D3 --> A3
    R3 --> A4
    B3 --> A5
    A1 & A2 & A3 & A4 & A5 --> A6

    style S3 fill:#ffcdd2
    style O3 fill:#f8bbd0
    style D3 fill:#e1bee7
    style R3 fill:#c5cae9
    style B3 fill:#b3e5fc
    style A6 fill:#c8e6c9
```

### 1.4 Response Structure

```mermaid
graph TB
    subgraph "JSON Response"
        R["<b>CMFRecommendationResponse</b><br/>├─ Recommendation: CMF_OK<br/>├─ OverallScore: 4.2<br/>├─ Confidence: High<br/>├─ Summary: String<br/>│<br/>├─ RuleScores[]<br/>│  ├─ S: {RuleId, Score:5, Eval}<br/>│  ├─ O: {RuleId, Score:4, Eval}<br/>│  ├─ D: {RuleId, Score:4, Eval}<br/>│  ├─ R: {RuleId, Score:3, Eval}<br/>│  └─ B: {RuleId, Score:4, Eval}<br/>│<br/>├─ Evidence<br/>│  ├─ Strengths[]<br/>│  ├─ Gaps[]<br/>│  └─ ImpactSentence<br/>│<br/>├─ MissingInformation[]<br/>├─ ReviewerActions[]<br/>├─ Timestamp<br/>└─ Platform"]
    end

    R -->|Sent to Frontend| UI["Recommendation Drawer Renders:<br/>1. Score Breakdown<br/>2. Reasoning<br/>3. Missing Info<br/>4. Action Items"]
    
    style R fill:#fff9c4
    style UI fill:#c8e6c9
```

---

## 2. Sighting Quality Assessment

### 2.1 Overall System Architecture

```mermaid
graph TB
    subgraph "Frontend Layer"
        A["CMF Pending Row / Details View"]
        B["Quality Assessment Button"]
        C["Quality Score Badge"]
        D["Quality Explanation Panel"]
    end

    subgraph "API Layer"
        E["GetSightingQualityAssessment Endpoint"]
        F["Request Validation"]
    end

    subgraph "Backend Processing"
        G["QualityAssessmentEngine"]
        Q1["Problem Statement Evaluator"]
        Q2["Customer Impact Evaluator"]
        Q3["Reproducibility Evaluator"]
        Q4["Platform/Scope Evaluator"]
        Q5["Logs/Evidence Evaluator"]
        Q6["Workaround Evaluator"]
        Q7["Owner Assignment Evaluator"]
        Q8["Business Impact Evaluator"]
        H["Quality Score Calculator"]
        I["Missing Information Mapper"]
        J["Explanation Generator"]
    end

    subgraph "Data"
        M["CMF Pending Sighting Data"]
        N["Quality Assessment Cache"]
        O["Quality Audit Trail"]
    end

    subgraph "Output"
        P["Quality Score (0-100%)"]
        Q["Missing Information List"]
        R["Quality Status: Complete/Partial/Incomplete"]
    end

    A -->|Click Quality| B
    B --> E
    E --> F
    F -->|Valid| G
    G --> Q1 & Q2 & Q3 & Q4 & Q5 & Q6 & Q7 & Q8
    Q1 & Q2 & Q3 & Q4 & Q5 & Q6 & Q7 & Q8 -->|Dimension Scores| H
    H --> I & J
    I & J -->|Output| P & Q & R
    P & Q & R -->|Display| D
    M -->|Feed| G
    G -.->|Cache| N

    style A fill:#e1f5ff
    style G fill:#fff3e0
    style P fill:#f3e5f5
```

### 2.2 Quality Assessment Flow

```mermaid
graph TD
    A["User Opens CMF Pending Sighting"] -->|Click Quality Button| B["Frontend Requests Assessment"]
    B --> C["Backend: Check Cache"]
    C -->|Hit| D["Return Cached Quality Score"]
    C -->|Miss| E["Extract 8 Quality Dimensions"]
    
    E --> E1["1. Problem Statement Clarity"]
    E --> E2["2. Customer Impact"]
    E --> E3["3. Reproducibility Detail"]
    E --> E4["4. Platform/System Scope"]
    E --> E5["5. Logs/Evidence"]
    E --> E6["6. Workaround/Recovery"]
    E --> E7["7. Owner Assignment"]
    E --> E8["8. Business/Milestone Impact"]
    
    E1 & E2 & E3 & E4 & E5 & E6 & E7 & E8 -->|Evaluate Presence & Quality| F["Score Each Dimension 0-100%"]
    F -->|Calculate| G["Overall Quality Score:<br/>Average of 8 dimensions"]
    G -->|Determine| H["Quality Status"]
    H -->|80-100%| H1["Status: COMPLETE"]
    H -->|50-79%| H2["Status: PARTIAL"]
    H -->|<50%| H3["Status: INCOMPLETE"]
    
    H1 & H2 & H3 -->|Identify| I["Missing Information:<br/>List gaps & priorities"]
    I -->|Generate| J["Explanation:<br/>What's present, what's missing, what to update"]
    J -->|Log| K["Audit Trail: Record assessment time & score"]
    K -->|Cache| L["Store for 1 hour TTL"]
    L -->|Response| M["Send to Frontend"]
    D -->|Response| M
    M -->|Render| N["Display Quality Panel:<br/>Score + Status + Gaps + Guidance"]

    style A fill:#e3f2fd
    style H1 fill:#c8e6c9
    style H2 fill:#ffe0b2
    style H3 fill:#ffccbc
    style N fill:#f3e5f5
```

### 2.3 Quality Dimension Scoring

```mermaid
graph TB
    subgraph "Dimension 1: Problem Statement"
        D1A["Present & Clear? ✓"] -->|Yes| D1B["Score: 100%"]
        D1A -->|Vague/Missing| D1C["Score: 20%"]
    end

    subgraph "Dimension 2: Customer Impact"
        D2A["Severity stated? ✓"] -->|Clear| D2B["Score: 100%"]
        D2A -->|Unclear| D2C["Score: 30%"]
    end

    subgraph "Dimension 3: Reproducibility"
        D3A["Rate/Steps provided? ✓"] -->|Yes| D3B["Score: 100%"]
        D3A -->|No| D3C["Score: 20%"]
    end

    subgraph "Dimension 4: Platform Scope"
        D4A["Platform specified? ✓"] -->|Yes| D4B["Score: 100%"]
        D4A -->|No| D4C["Score: 40%"]
    end

    subgraph "Dimension 5: Logs/Evidence"
        D5A["Logs attached? ✓"] -->|Yes| D5B["Score: 100%"]
        D5A -->|No| D5C["Score: 10%"]
    end

    subgraph "Dimension 6: Workaround"
        D6A["Workaround stated? ✓"] -->|Yes| D6B["Score: 100%"]
        D6A -->|No| D6C["Score: 50%"]
    end

    subgraph "Dimension 7: Owner"
        D7A["Owner assigned? ✓"] -->|Yes| D7B["Score: 100%"]
        D7A -->|No| D7C["Score: 0%"]
    end

    subgraph "Dimension 8: Business Impact"
        D8A["Gate/Milestone linked? ✓"] -->|Yes| D8B["Score: 100%"]
        D8A -->|No| D8C["Score: 40%"]
    end

    D1B & D1C & D2B & D2C & D3B & D3C & D4B & D4C & D5B & D5C & D6B & D6C & D7B & D7C & D8B & D8C -->|Average| FINAL["Overall Quality Score"]
    
    FINAL -->|Color-coded| COLOR["🟢 Complete: 80%+<br/>🟡 Partial: 50-79%<br/>🔴 Incomplete: <50%"]

    style COLOR fill:#fff9c4
```

---

## 3. Similar Issue Intelligence

### 3.1 Overall System Architecture

```mermaid
graph TB
    subgraph "Frontend Layer"
        A["CMF Pending Row"]
        B["Similar Issues Button"]
        C["Similar Issues Drawer"]
    end

    subgraph "API Layer"
        E["GetSimilarIssues Endpoint"]
        F["Query Validation"]
    end

    subgraph "Backend Processing"
        G["SimilarityMatcher Engine"]
        M1["Component Matcher"]
        M2["Platform Matcher"]
        M3["Symptom/Keyword Matcher"]
        M4["Error Code Matcher"]
        M5["Title Similarity Scorer"]
        M6["Debug Summary Matcher"]
        H["Similarity Score Aggregator"]
        I["Duplicate Detector"]
        J["Similar Issue Ranker"]
    end

    subgraph "Data Sources"
        D1["Closed CMF Issues"]
        D2["Existing Pending Sightings"]
        D3["HSD-Linked Issues"]
        D4["Past Promoted Tickets"]
        D5["Similarity Index/Cache"]
    end

    subgraph "Output"
        P["Top Matching Issues (5-10)"]
        Q["Similarity Scores & Reasons"]
        R["Previous Disposition/Fix"]
    end

    A -->|Click Similar Issues| B
    B --> E
    E --> F
    F -->|Valid| G
    G --> M1 & M2 & M3 & M4 & M5 & M6
    M1 & M2 & M3 & M4 & M5 & M6 -->|Match Scores| H
    H -->|Rank| J
    J -->|Detect| I
    I & J -->|Output| P & Q & R
    D1 & D2 & D3 & D4 -->|Query| G
    G -.->|Cache| D5

    style A fill:#e1f5ff
    style G fill:#fff3e0
    style P fill:#f3e5f5
```

### 3.2 Similar Issue Detection Flow

```mermaid
graph TD
    A["User Views CMF Pending Sighting"] -->|Click Similar Issues| B["Frontend Sends Sighting Context"]
    B -->|Component, Title, Impact, Logs, Keywords| C["Backend: Check Similarity Cache"]
    C -->|Hit| D["Return Cached Similar Issues"]
    C -->|Miss| E["Query Multiple Data Sources"]
    
    E --> E1["Query Closed CMF Issues"]
    E --> E2["Query Existing Pending Sightings"]
    E --> E3["Query HSD Linked Issues"]
    E --> E4["Query Past Promoted Tickets"]
    
    E1 & E2 & E3 & E4 -->|Retrieve Candidates| F["Score Similarity Across 6 Dimensions"]
    
    F --> F1["1. Component Match"]
    F --> F2["2. Platform Match"]
    F --> F3["3. Error Code/Symptom Match"]
    F --> F4["4. Keywords Match"]
    F --> F5["5. Title Similarity"]
    F --> F6["6. Debug Summary Similarity"]
    
    F1 & F2 & F3 & F4 & F5 & F6 -->|Combine Scores| G["Calculate Overall Similarity 0-100%"]
    G -->|Rank| H["Sort by Similarity Score (descending)"]
    H -->|Detect| I["Identify Likely Duplicates:<br/>Similarity > 85%"]
    I -->|Flag| I1["Mark as 'Possible Duplicate'"]
    H -->|Show| J["Extract Top 5-10 Matches"]
    
    J -->|Include| K["For Each Match:<br/>- Similarity Score<br/>- Why Similar<br/>- Previous Disposition<br/>- Fixed Version<br/>- Owner/Component"]
    K -->|Log| L["Cache Results for 4 hours"]
    L -->|Response| M["Send Similar Issues List"]
    D -->|Response| M
    M -->|Render| N["Display Drawer:<br/>Similar Issues + Duplicates + Previous Decisions"]

    style A fill:#e3f2fd
    style I1 fill:#ffcdd2
    style N fill:#f3e5f5
```

### 3.3 Similarity Matching Logic

```mermaid
graph LR
    subgraph "Input Sighting"
        INPUT["Component: FIRMWARE<br/>Platform: PTL<br/>Title: Hang on resume<br/>Keywords: S3, hang, resume<br/>Error: 0x8000XXXX"]
    end

    subgraph "Matching Candidates"
        C1["Closed Issue:<br/>FIRMWARE, PTL<br/>Title: S3 hang issue<br/>Score: ?"]
        C2["Pending Sighting:<br/>FIRMWARE, LNL<br/>Title: Hang problem<br/>Score: ?"]
        C3["HSD-8765:<br/>Hang on platform<br/>Same error code<br/>Score: ?"]
    end

    subgraph "Dimension Scoring"
        M1["Component Match: FIRMWARE=FIRMWARE? 100%"]
        M2["Platform Match: PTL=PTL? 100%, PTL≠LNL? 0%"]
        M3["Error Code Match: 0x8000=0x8000? 100%"]
        M4["Keywords: 'hang', 'resume', 'S3'? Partial"]
        M5["Title Similarity: Levenshtein distance"]
    end

    INPUT -->|Compare| C1 & C2 & C3
    C1 -->|Evaluate| M1 & M2 & M3 & M4 & M5
    M1 & M2 & M3 & M4 & M5 -->|Aggregate| RESULT["C1: 92% similar<br/>C2: 65% similar<br/>C3: 88% similar"]
    RESULT -->|Rank| RANKED["Top Similar:<br/>1. C1 (92%)<br/>2. C3 (88%)<br/>3. C2 (65%)"]
    RANKED -->|Display| OUTPUT["Show top 3 with reasons"]

    style RESULT fill:#fff9c4
    style OUTPUT fill:#c8e6c9
```

---

## 4. AI-Assisted Initial Debug Triage

### 4.1 Overall System Architecture

```mermaid
graph TB
    subgraph "Frontend Layer"
        A["CMF Pending Row / Details"]
        B["AI Debug Triage Button"]
        C["Artifact Upload"]
        D["Triage Result Drawer"]
    end

    subgraph "API Layer"
        E["GetDebugTriage Endpoint"]
        F["File Upload Handler"]
    end

    subgraph "Backend Processing"
        G["DebugTriageEngine"]
        P1["Artifact Parser"]
        P2["Log Text Extractor"]
        P3["Crash Dump Analyzer"]
        P4["Image/Screenshot Parser"]
        
        E1["Error Code Extractor"]
        E2["Exception Matcher"]
        E3["Module/Driver Detector"]
        E4["Stack Trace Analyzer"]
        E5["Keyword Extractor"]
        
        D1["Domain Classifier"]
        D2["Failure Stage Identifier"]
        D3["Debug Direction Recommender"]
        D4["Missing Data Analyzer"]
        
        G1["Triage Result Generator"]
    end

    subgraph "Data"
        M["Artifact Storage"]
        N["Known Error Codes DB"]
        O["Domain Mapping"]
        P["Triage Cache"]
    end

    subgraph "Output"
        Q["Failure Signatures"]
        R["Likely Domain"]
        S["Failure Stage"]
        T["Debug Direction"]
        U["Missing Data List"]
    end

    A -->|Upload Artifacts| C
    C -->|Files| F
    F --> E
    E -->|Parse| G
    G --> P1 & P2 & P3 & P4
    P1 & P2 & P3 & P4 -->|Extract Data| E1 & E2 & E3 & E4 & E5
    E1 & E2 & E3 & E4 & E5 -->|Analyze| D1 & D2 & D3 & D4
    D1 & D2 & D3 & D4 -->|Generate| G1
    G1 -->|Output| Q & R & S & T & U
    Q & R & S & T & U -->|Display| D
    M -.->|Store| G
    N & O -.->|Lookup| G

    style A fill:#e1f5ff
    style G fill:#fff3e0
    style D fill:#f3e5f5
```

### 4.2 Debug Triage Flow

```mermaid
graph TD
    A["User Opens CMF Pending Sighting"] -->|Click AI Debug Triage| B["File Upload Dialog"]
    B -->|User Uploads Logs/Dumps/Screenshots| C["File Received"]
    C --> D["Validate & Scan Files"]
    D -->|Valid| E["Parse Artifacts"]
    D -->|Invalid/Unsafe| F["Error: Unsupported format"]
    
    E --> E1["Extract Text from Logs"]
    E --> E2["Parse Crash Dump Metadata"]
    E --> E3["Extract Text from Screenshots"]
    E --> E4["Normalize Timestamps & Formats"]
    
    E1 & E2 & E3 & E4 -->|Clean Data| G["Extract Failure Signatures"]
    
    G --> G1["Identify Error Codes"]
    G --> G2["Identify Exception Names"]
    G --> G3["Identify Crash Signatures"]
    G --> G4["Identify Keywords: hang, crash, fail, etc."]
    G --> G5["Identify Module/Driver Names"]
    
    G1 & G2 & G3 & G4 & G5 -->|Compile| H["Failure Signature List"]
    H -->|Analyze| I["Classify Failure Stage"]
    
    I -->|Match Patterns| I1["Boot? Install? Runtime? Suspend? Etc."]
    I -->|Infer| I2["Last good stage vs First bad stage"]
    
    I2 -->|Map| J["Classify Likely Domain"]
    J -->|Match| J1["BIOS/FW? Driver? OS? HW? Graphics? Power?"]
    J -->|Rank| J2["Top 3 likely domains with confidence"]
    
    J2 & H -->|Generate| K["Initial Debug Direction"]
    K -->|Include| K1["What likely failed"]
    K -->|Include| K2["Where to start investigation"]
    K -->|Include| K3["Which owner to contact"]
    K -->|Include| K4["Next debug actions"]
    
    K -->|Identify| L["Missing Information"]
    L -->|Analyze| L1["Full sysdebug? Repro steps? Version? Symbols?"]
    L -->|Prioritize| L2["Required / Helpful / Optional"]
    
    K & L -->|Log| M["Audit Trail: Store triage inputs & outputs"]
    M -->|Response| N["Build Triage Result JSON"]
    N -->|Render| O["Display Triage Drawer:<br/>Signatures + Domain + Stage + Direction + Missing Data"]
    F -->|Display| O

    style A fill:#e3f2fd
    style O fill:#f3e5f5
```

### 4.3 Artifact Analysis Pipeline

```mermaid
graph TB
    subgraph "Input Artifacts"
        A1["system.log"]
        A2["crashdump.dmp"]
        A3["screenshot.png"]
    end

    subgraph "Parsing"
        P1["Extract Text<br/>Detect Errors<br/>Timestamp Sync"]
        P2["Read Headers<br/>Exception Code<br/>Faulting Module"]
        P3["OCR if needed<br/>Extract UI Text"]
    end

    subgraph "Signature Extraction"
        S1["Error Codes:<br/>0x8000XXXX<br/>0xC0000XXX"]
        S2["Exceptions:<br/>Access Violation<br/>Stack Overflow"]
        S3["Modules:<br/>driver.sys<br/>firmware.bin"]
        S4["Keywords:<br/>HANG, CRASH<br/>TIMEOUT"]
    end

    subgraph "Analysis"
        A["Domain Match:<br/>Driver issue?"]
        B["Stage Match:<br/>Boot stage?"]
        C["Severity Infer:<br/>Customer impact?"]
    end

    subgraph "Output"
        O1["Primary Signature"]
        O2["Secondary Signals"]
        O3["Confidence Level"]
        O4["Recommendation"]
    end

    A1 & A2 & A3 -->|Process| P1 & P2 & P3
    P1 & P2 & P3 -->|Extract| S1 & S2 & S3 & S4
    S1 & S2 & S3 & S4 -->|Analyze| A & B & C
    A & B & C -->|Compile| O1 & O2 & O3 & O4

    style O1 fill:#c8e6c9
    style O4 fill:#fff9c4
```

---

## 5. UI Changes

### 5.1 CMF Pending List Layout - Before & After

```mermaid
graph LR
    subgraph "BEFORE: Basic Grid"
        B1["Component<br/>Owner<br/>Customer<br/>Impact<br/>Status"]
    end

    subgraph "AFTER: AI-Enhanced Layout"
        A1["Component<br/>Owner<br/>Customer<br/>Impact"]
        A2["AI Status Badge<br/>Quality Score<br/>Priority Badge<br/>Aging Badge"]
        A3["Actions:<br/>Recommendation<br/>Quality<br/>Debug Triage<br/>Similar Issues"]
    end

    B1 -->|Redesign| A1 & A2 & A3

    style A2 fill:#fff3e0
    style A3 fill:#f3e5f5
```

### 5.2 CMF Pending List Component Structure

```mermaid
graph TB
    subgraph "CMF Pending List View"
        TOP["<b>CMF Pending Summary</b><br/>Total: 45 | Overdue: 8 | High Risk: 12 | Milestone Blocking: 3"]
        
        FILTER["<b>Filter Bar</b><br/>┌─ Component Dropdown<br/>├─ Owner Dropdown<br/>├─ Customer Dropdown<br/>├─ iDST Dropdown<br/>├─ Recommendation Status<br/>├─ Quality Score Range<br/>└─ Priority Filter"]
        
        subgraph "Data Grid"
            HEADER["Component | Owner | Customer | Impact | AI Status | Quality | Priority | Age | Actions"]
            
            ROW1["FW | john | Acme | High | CMF_OK ✓ | 95% | P0 | 2d | [Rec] [Quality] [Similar]"]
            ROW2["Driver | jane | XYZ Corp | Critical | CMF_REVIEW ? | 72% | P1 | 5d | [Rec] [Quality] [Debug]"]
            ROW3["OS | bob | TBD | Medium | CMF_INCOMPLETE ! | 45% | P2 | 1d | [Rec] [Quality]"]
        end
        
        FOOTER["<b>Summary Stats</b><br/>AI Recommendations: 38/45 | Avg Quality: 68% | Avg Priority: P1.2"]
    end

    TOP --> FILTER
    FILTER --> HEADER
    HEADER --> ROW1 & ROW2 & ROW3

    style TOP fill:#e3f2fd
    style FILTER fill:#fff3e0
    style ROW1 fill:#c8e6c9
    style ROW2 fill:#ffe0b2
    style ROW3 fill:#ffccbc
```

### 5.3 Recommendation Drawer Structure

```mermaid
graph TB
    subgraph "Recommendation Drawer (Right Panel)"
        HEADER["<b>AI CMF Recommendation</b><br/>Sighting ID: CMF-12345"]
        
        subgraph "Score Breakdown"
            SCORE["<b>Overall Score: 4.2/5 (84%)</b><br/>🟢 CMF_OK Recommended"]
            
            RULES["S: 5/5 🔴 | O: 4/5 🟠 | D: 4/5 🟠 | R: 3/5 🟡 | B: 4/5 🟠"]
        end
        
        subgraph "Evidence & Reasoning"
            REASONING["<b>Why CMF_OK?</b><br/>1. Platform-wide failure (S=5)<br/>2. Affects 3+ customers weekly (O=4)<br/>3. Blocks validation gate (B=4)<br/>4. Users hit during standard workflow (D=4)"]
            
            MISSING["<b>Missing Information:</b><br/>• Exact reproduction steps<br/>• Workaround timeline"]
        end
        
        subgraph "Actions"
            ACTIONS["<b>Reviewer Should:</b><br/>✓ Confirm escalation status<br/>✓ Approve CMF tagging<br/>✓ Set fix target date<br/>⚠ Follow up on workaround cost"]
        end
        
        BUTTONS["[Copy to Report] [Regenerate] [Useful] [Not Useful]"]
    end

    HEADER --> SCORE
    SCORE --> RULES
    RULES --> REASONING
    REASONING --> MISSING
    MISSING --> ACTIONS
    ACTIONS --> BUTTONS

    style HEADER fill:#e3f2fd
    style SCORE fill:#c8e6c9
    style REASONING fill:#fff9c4
    style MISSING fill:#ffccbc
    style ACTIONS fill:#f3e5f5
```

### 5.4 Multi-Drawer Navigation

```mermaid
graph TB
    subgraph "CMF Pending Row Actions"
        ROW["CMF-12345 | FW | John | Acme | High Impact"]
        
        subgraph "Action Buttons"
            REC["[AI Recommendation]"]
            QUAL["[Quality Score]"]
            SIM["[Similar Issues]"]
            TRI["[Debug Triage]"]
        end
    end

    subgraph "Drawer 1: Recommendation"
        D1["Score + Reasoning + Missing Info<br/>+ Reviewer Actions"]
    end

    subgraph "Drawer 2: Quality"
        D2["Quality Score (72%)<br/>Missing Fields List<br/>Update Guidance"]
    end

    subgraph "Drawer 3: Similar Issues"
        D3["Top 5 Similar Issues<br/>Confidence Scores<br/>Previous Decisions"]
    end

    subgraph "Drawer 4: Debug Triage"
        D4["Failure Signatures<br/>Domain Classification<br/>Debug Direction<br/>Missing Data"]
    end

    ROW --> REC & QUAL & SIM & TRI
    REC -->|Show| D1
    QUAL -->|Show| D2
    SIM -->|Show| D3
    TRI -->|Show| D4

    style D1 fill:#f3e5f5
    style D2 fill:#fff3e0
    style D3 fill:#fce4ec
    style D4 fill:#e0f2f1
```

---

## 6. Aging, Priority and Accountability

### 6.1 Overall System Architecture

```mermaid
graph TB
    subgraph "Frontend Layer"
        A["CMF Pending List View"]
        B["Aging Calculation Display"]
        C["Priority Badge"]
        D["Owner Assignment View"]
        E["Overdue Notifications"]
    end

    subgraph "API Layer"
        F["CalculateAgingAndPriority Endpoint"]
        G["GetNotificationRecipients Endpoint"]
    end

    subgraph "Backend Processing"
        H["AgingPriorityEngine"]
        A1["Aging Calculator"]
        A2["CMF_ASK Tracker"]
        A3["Review Status Tracker"]
        P1["Priority Scorer"]
        P2["Risk Evaluator"]
        P3["Milestone Blocker Detector"]
        P4["Owner Resolver"]
        N1["Notification Trigger"]
        N2["Notification Builder"]
        N3["Escalation Logic"]
    end

    subgraph "Data"
        M["CMF Pending Sightings"]
        N["Review History"]
        O["Notification Log"]
        P["Owner Assignment Map"]
    end

    subgraph "Output"
        Q["Aging Days"]
        R["Overdue Flags"]
        S["Priority Level"]
        T["Owner List"]
        U["Notifications Sent"]
    end

    A -->|Display| B & C & D
    B & C & D --> F
    F -->|Calculate| H
    H --> A1 & A2 & A3 & P1 & P2 & P3 & P4
    A1 & A2 & A3 & P1 & P2 & P3 & P4 -->|Output| Q & R & S & T
    Q & R & S & T -->|Trigger| N1
    N1 -->|Build| N2
    N2 -->|Send| N3
    N3 -->|Log| O
    O -->|Update| E

    style A fill:#e1f5ff
    style H fill:#fff3e0
    style U fill:#f3e5f5
```

### 6.2 Aging & Priority Calculation Flow

```mermaid
graph TD
    A["Scheduled Job Runs Every Hour"] -->|Fetch| B["All CMF Pending Sightings"]
    
    B -->|For Each| C["Get CMF_ASK Date"]
    C -->|Calculate| D["Days Since CMF_ASK = TODAY - CMF_ASK"]
    D -->|Bucket| D1["0-1 day = FRESH<br/>2 days = OVERDUE<br/>3-5 days = STALE<br/>>5 days = VERY_STALE"]
    
    D1 -->|Check| E["Has Review Happened? (Last Review Date)"]
    E -->|No Review for >2 days| F["Set Flag: OVERDUE_REVIEW"]
    E -->|Recent Review| G["Clear Flag"]
    
    F & G -->|Input to Priority Score| H["Calculate Priority = f(Age, Risk, Milestone)"]
    
    H -->|Age Component| H1["0-1d: +0 pts<br/>2d: +20 pts<br/>3-5d: +40 pts<br/>>5d: +60 pts"]
    H -->|Risk Component| H2["Low: +0 pts<br/>Medium: +20 pts<br/>High: +40 pts<br/>Critical: +60 pts"]
    H -->|Milestone Component| H3["Not Blocking: +0 pts<br/>Blocking: +40 pts"]
    
    H1 & H2 & H3 -->|Sum| H4["Total Score (0-160)"]
    H4 -->|Map to Level| I["P0: 120-160 (Immediate)<br/>P1: 80-119 (High)<br/>P2: 40-79 (Normal)<br/>P3: 0-39 (Low)"]
    
    I -->|Store| J["Update Database:<br/>- Aging Days<br/>- Priority Level<br/>- Overdue Flag<br/>- Calculation Timestamp"]
    J -->|Identify| K["Sightings needing Notification"]
    K -->|Check| K1["Overdue review?<br/>Milestone blocking?<br/>First time calculated?"]
    K1 -->|Yes| L["Send Notification to Owner"]
    K1 -->|No| M["Skip notification"]

    style I fill:#fff9c4
    style L fill:#ffccbc
```

### 6.3 Owner Assignment & Accountability

```mermaid
graph TD
    A["CMF Pending Sighting"]
    A -->|Has Owner?| B["Owner Assignment Status"]
    
    B -->|Explicitly Assigned| C["Direct Owner"]
    B -->|Missing| D["Lookup by Component"]
    
    C & D -->|Get| E["Responsible Reviewer"]
    E -->|Retrieve| E1["Name, Email, Team"]
    
    E1 -->|Check| F["Escalation Logic"]
    F -->|Owner Missing| G["Notify Component Lead"]
    F -->|Overdue >2d| H["Notify Owner + Manager"]
    F -->|Milestone Blocking + Overdue| I["Escalate to Director"]
    
    G & H & I -->|Build Message| J["Notification Content:<br/>Sighting ID<br/>Title<br/>Age Since CMF_ASK<br/>Priority<br/>Action Required<br/>Deep Link"]
    
    J -->|Send Via| K["Portal Notification<br/>Email<br/>Teams Message"]
    
    K -->|Log| L["Audit Trail:<br/>- Who notified<br/>- When<br/>- Notification type<br/>- Recipient response"]
    
    L -->|Track| M["Prevent Duplicate Notifications<br/>within 24 hours"]

    style C fill:#c8e6c9
    style G fill:#ffccbc
    style H fill:#ffccbc
    style I fill:#ffcdd2
```

### 6.4 Notification & Escalation Workflow

```mermaid
graph TB
    subgraph "Trigger Events"
        T1["Sighting Created"]
        T2["Sighting Reaches 2 Days Old"]
        T3["Sighting is Milestone Blocking"]
        T4["Manual Escalation"]
    end

    subgraph "Notification Rules"
        R1["New Sighting + Owner Assigned → Notify Owner"]
        R2["Overdue (>2d) + No Review → Notify Owner + Manager"]
        R3["Milestone Blocking + Overdue → Escalate to Director"]
        R4["Missing Owner → Notify Component Lead"]
    end

    subgraph "Escalation Matrix"
        E1["P0 Immediate: Director + VP"]
        E2["P1 High: Manager + Owner"]
        E3["P2 Normal: Owner"]
        E4["P3 Low: Email only"]
    end

    subgraph "Notification Channels"
        C1["Portal In-App Alert"]
        C2["Email"]
        C3["Teams Chat"]
        C4["Dashboard Highlight"]
    end

    T1 & T2 & T3 & T4 -->|Evaluate| R1 & R2 & R3 & R4
    R1 & R2 & R3 & R4 -->|Map Priority| E1 & E2 & E3 & E4
    E1 & E2 & E3 & E4 -->|Route To| C1 & C2 & C3 & C4

    style T1 fill:#e3f2fd
    style T3 fill:#ffccbc
    style E1 fill:#ffcdd2
    style C1 fill:#f3e5f5
```

### 6.5 Dashboard Summary View

```mermaid
graph TB
    subgraph "CMF Pending Dashboard"
        STATS["<b>Summary Statistics</b><br/>Total Pending: 45<br/>Overdue (>2d): 8<br/>Milestone Blocking: 3<br/>Missing Owner: 2"]
        
        subgraph "Age Distribution"
            AGE["0-1 day: 15<br/>2 days: 12 ⚠️<br/>3-5 days: 10 ⚠️<br/>>5 days: 8 🔴"]
        end
        
        subgraph "Priority Queue"
            PRI["P0 (Immediate): 3<br/>P1 (High): 12<br/>P2 (Normal): 20<br/>P3 (Low): 10"]
        end
        
        subgraph "Reviewer Workload"
            WORK["John: 8 items (2 overdue)<br/>Jane: 12 items (3 overdue)<br/>Bob: 6 items (0 overdue)<br/>Unassigned: 19 items"]
        end
        
        subgraph "Overdue Items"
            OVR["CMF-12345 | FW | John | 5 days old 🔴<br/>CMF-12346 | Driver | Jane | 3 days old ⚠️<br/>CMF-12347 | OS | Unassigned | 2 days old ⚠️"]
        end
    end

    STATS --> AGE & PRI & WORK & OVR

    style STATS fill:#e3f2fd
    style AGE fill:#ffebee
    style PRI fill:#fff3e0
    style WORK fill:#e8f5e9
    style OVR fill:#ffccbc
```

---

## Summary: Development Phases & Timeline

```mermaid
graph LR
    subgraph "Phase 1: Foundations (Weeks 1-2)"
        P1A["UI Changes"]
        P1B["Aging/Priority/Accountability"]
    end

    subgraph "Phase 2: Decision Support (Weeks 3-6)"
        P2A["Quality Assessment"]
        P2B["AI CMF Recommendation"]
    end

    subgraph "Phase 3: Intelligence (Weeks 7-10)"
        P3A["Similar Issue Intelligence"]
        P3B["AI Debug Triage"]
    end

    subgraph "Phase 4: Testing & Rollout (Weeks 11-12)"
        P4A["Integration Testing"]
        P4B["User Acceptance Testing"]
        P4C["Production Deployment"]
    end

    P1A & P1B -->|Enable| P2A & P2B
    P2A & P2B -->|Feed| P3A & P3B
    P3A & P3B -->|Validate| P4A
    P4A -->|QA| P4B
    P4B -->|Deploy| P4C

    style P1A fill:#c8e6c9
    style P1B fill:#c8e6c9
    style P2A fill:#fff3e0
    style P2B fill:#fff3e0
    style P3A fill:#fce4ec
    style P3B fill:#fce4ec
    style P4A fill:#f3e5f5
    style P4B fill:#f3e5f5
    style P4C fill:#e0f2f1
```

---

## Key Architectural Principles

### 1. **Modularity**
   - Each feature operates independently with clear interfaces
   - Backend services can be tested in isolation
   - UI components are reusable

### 2. **Caching Strategy**
   - Quality Assessment: 1 hour TTL
   - Recommendation: 30 minutes TTL
   - Similar Issues: 4 hours TTL
   - Aging/Priority: Real-time (hourly job)

### 3. **Audit & Compliance**
   - All AI-generated outputs logged with context
   - User actions tracked for accountability
   - 12-month retention policy

### 4. **Error Handling & Fallbacks**
   - Graceful degradation if service fails
   - Cache fallback when AI service unavailable
   - Clear error messages to users

### 5. **Performance Targets**
   - API responses: <3 seconds (p95)
   - Concurrent users: 50+
   - Database queries: <5ms (audit reports)
   - System uptime: 99.5%

---

**End of Architecture Diagrams Document**
