# RAYVAANAH STRATEGIC DOCUMENT

**Prepared for:** Ayushmaan Chandra
**Organization:** Rayvaanah — Financial Systems Division
**Document:** Stage 2, Module A — Payment Page Security & E-Skimming Scope (PCI DSS 6.4.3 / 11.6.1)
**Date:** 17 August 2026
**Classification:** Internal / Advisor-Restricted
**Status:** Analysis complete for this module. Full Stage 2 CDE scoping remains blocked on the existing AOC scope statement (Q1.5).

---

## MODULE OPENING FRAME

### What we are determining

How Rayvaanah's payment-page architecture — hosted checkout, payment links, embedded fields, merchant SDK — determines who carries PCI DSS Requirements 6.4.3 and 11.6.1, and what Rayvaanah must build, document and evidence as a result.

### Why it matters

This is the one PCI DSS scope dimension that **does not shrink when you stop touching cardholder data**. Requirements 6.4.3 and 11.6.1 attach to *scripts on payment pages and the pages that embed them*, not to PAN storage. An architecture can be perfectly tokenised, hold no card data anywhere, and still be fully in scope for these two requirements.

For Model A/C (TSP/PG), where the entire Stage 1 strategy rests on **not** handling funds or card data, this is where the residual PCI obligation actually lives.

### Assumptions used in this module

| # | Assumption | Status |
|---|---|---|
| B1 | Rayvaanah will offer a hosted checkout page and/or payment links as part of the pay-in module | Per platform blueprint |
| B2 | Merchant portal and admin console are Next.js single-page applications | Per D9 build decisions — **material, see §4** |
| B3 | Rayvaanah occupies the TPSP role in the supplement's terminology when serving merchants | Follows Stage 1 Model A/C |
| B4 | Card acceptance is in scope at some horizon (row 8 of the Stage 1 matrix) | **Unconfirmed** — if cards are permanently out of scope, this module is deferred, not deleted |

### What must be confirmed externally

1. Whether Rayvaanah validates as a **service provider** (SAQ D for Service Providers or ROC) — determined by the acquirer, payment brand, or compliance-accepting entity, **not** self-selected.
2. Whether the existing AOC covers any payment-page environment at all (Q1.5 from Stage 1, still open).
3. Which sponsor PA/acquirer accepts Rayvaanah's compliance documentation, since that entity sets the validation route.

---

## 1. OVERVIEW — WHAT THIS DOCUMENT IS, AND WHAT IT IS NOT

**Source:** PCI SSC, *Information Supplement: Payment Page Security and Preventing E-Skimming — Guidance for PCI DSS Requirements 6.4.3 and 11.6.1*, Version 1.0 Revision 1, April 2025.

**Classification for our purposes — this matters under the master prompt's requirement discipline:**

| | |
|---|---|
| **Is it a legal requirement?** | **No.** Not law in India or anywhere. |
| **Is it a PCI DSS requirement?** | **No.** The supplement states on every page that it does not replace or supersede requirements in any PCI SSC standard. It adds nothing to the standard. |
| **What is it, then?** | **Authoritative interpretive guidance** on requirements that *are* mandatory: 6.4.3 and 11.6.1, both of which were future-dated in v4.0 and became mandatory on 31 March 2025. |
| **Why it still binds in practice** | QSAs and ISAs assess against the standard, but they read scope and adequacy through the Council's guidance. Departing from it is defensible; departing from it without a documented reason is not. |
| **Revision note** | Rev 1 (April 2025) corrected the redirection-mechanism guidance on p.14 to align with p.11. Anyone working from the March 2025 v1.0 has the wrong redirection position — **check which version any vendor or consultant is quoting.** |

**The requirements themselves, restated:**

- **6.4.3** — every payment page script loaded and executed in the consumer's browser must be (a) authorised by a defined method, (b) integrity-assured by a defined method, and (c) inventoried with written business or technical justification.
- **11.6.1** — a change- and tamper-detection mechanism must alert personnel to unauthorised modification of security-impacting HTTP headers and payment page script content **as received by the consumer browser**, evaluating both, performed **at least weekly** or at a frequency set by a targeted risk analysis under 12.3.1.

The phrase "as received by the consumer browser" is the crux. Server-side file integrity monitoring does not satisfy 11.6.1. The control must observe what the browser actually gets.

---

## 2. STRATEGIC INSIGHT

> **As a TPSP, Rayvaanah has no payment-page scenario with zero responsibility. The merchant does. Rayvaanah never does.**

The supplement's applicability table (Table 3) sets out five payment page scenarios. In four of them the merchant carries responsibility for scripts on its own pages. In the fifth — a fully outsourced merchant website — the merchant carries **nothing** related to 6.4.3 and 11.6.1.

The TPSP column reads differently. In **all five scenarios**, the TPSP is responsible for any scripts it includes for the services it provides.

This inverts the intuitive read of Stage 1. The Model A/C strategy minimises regulatory exposure by pushing fund handling and the compliance decision up to Layer 3. But **6.4.3 and 11.6.1 push the other way** — the more of the payment experience Rayvaanah hosts on behalf of merchants, the more of this specific obligation concentrates on Rayvaanah.

That is not a reason to avoid hosting. It is a reason to price it, staff it and build for it deliberately, because it is also the strongest commercial asset in the module:

**Every unit of 6.4.3/11.6.1 burden Rayvaanah absorbs is burden a merchant does not carry.** A merchant on a fully outsourced flow carries nothing here. That is a concrete, evidenceable sales proposition to small merchants who cannot run a CSP programme, maintain a script inventory, or operate weekly tamper detection. It is the difference between a merchant qualifying for the lightest self-assessment route and being pushed into a heavier one.

**The strategic reading:** absorb this obligation on purpose, build it once, operate it centrally, and sell the relief. Do not let it arrive by accident through architecture choices nobody costed.

---

## 3. RESPONSIBILITY SPLIT MAPPED TO RAYVAANAH'S PRODUCTS

| Rayvaanah product | Supplement scenario | Merchant carries | Rayvaanah (TPSP) carries | Merchant PCI burden |
|---|---|---|---|---|
| **Payment link sent to payer** (email/SMS/WhatsApp, payer goes directly to Rayvaanah's page) | Fully outsourced merchant website | **Nothing** under 6.4.3/11.6.1 | All scripts on the hosted page | **Lowest available** |
| **Hosted checkout via merchant-page redirect** | Redirection mechanism | Any scripts on the merchant page that carries the redirect (the non-payment page) | All scripts on the hosted page | Low, but **not zero** |
| **Embedded fields / iframe** | Embedded payment forms | Any scripts on the parent page embedding the iframe | Scripts inside the iframe (the payment page) | Medium — split responsibility |
| **Direct-post from merchant form** | Direct post payment | Any scripts on the merchant's pages | Any scripts Rayvaanah supplies | High |
| **Merchant-hosted form posting server-side** | Merchant-posted payment | Any scripts on the merchant's pages | Any scripts Rayvaanah supplies | **Highest — card data traverses the merchant environment** |

### The distinction that is easy to miss

**Payment link and redirect look similar to a product manager and are different to an assessor.**

- Payer receives a link out-of-band and lands directly on Rayvaanah's page → merchant page never participates → merchant carries nothing.
- Payer is on the merchant's site and the merchant's page sends them to Rayvaanah → the merchant's page is the non-payment page that carries the redirect → **all scripts on that merchant page are in the merchant's 6.4.3/11.6.1 scope.**

The commercial consequence is real. If Rayvaanah wants to advertise "we remove your payment page compliance burden entirely," only the first flow supports that claim. This should be reflected in product naming, merchant documentation, and the integration guide — not left for a QSA to discover in year two.

### Two further points from the supplement worth noting

- **Iframes do not remove the parent page from scope.** Embedding a third-party payment form reduces the number of applicable requirements for the merchant's page but does not remove the page from scope or make 6.4.3/11.6.1 inapplicable to it. Any merchant-facing collateral claiming otherwise should be corrected.
- **3DS carve-out.** Validation to 6.4.3 is not required for 3DS scripts, on the basis of the trust relationship established through merchant due diligence and the business agreement. Any script running for a purpose beyond 3DS functionality remains fully in scope. Narrow, and not a general exemption.

---

## 4. THE SPA FINDING — THIS ONE HITS THE EXISTING BUILD

The supplement draws a hard distinction between multi-page applications and single-page applications:

- **Multi-page:** each navigation loads fresh, purging prior scripts from browser memory. Typically only the parent page embedding the payment page is in scope for the merchant's 6.4.3/11.6.1 assessment.
- **Single-page:** the browser never fully reloads; scripts loaded at any point in the session stay resident and keep running. The whole SPA behaves as one continuous page. **6.4.3 and 11.6.1 therefore apply to every view in the application.**

**Applied to the D9 stack:** the merchant portal and admin console are Next.js SPAs sharing a component library. If a payment-capture surface is ever rendered inside either of those applications — a "take a payment" view, a virtual terminal, a card-on-file capture in settings, a test-transaction screen in the developer portal — then **every view in that application, and every script it loads, enters 6.4.3 and 11.6.1 scope.** That includes analytics, session replay, support-chat widgets, feature flags, error reporting, and anything the component library pulls in.

That is a scope explosion measured in dozens of third-party scripts, each needing authorisation, integrity assurance, inventory, written justification, and weekly tamper detection.

### Architectural decision this forces

> **The hosted payment page must be a separate application, on a separate origin, with a deliberately minimal script budget — and it must never be a view inside the merchant portal or admin console SPA.**

Concretely:
- Dedicated origin (e.g. a distinct checkout subdomain), separate deployment, separate CI/CD pipeline.
- Multi-page or minimally-scripted, not an SPA.
- No analytics, no tag manager, no session replay, no chat widget, no A/B tooling on that origin. Ever. Each one is a script requiring authorisation, integrity assurance, justification and monitoring, and each is a documented e-skimming vector.
- No shared component library with the portals, because shared dependencies drag the portals' transitive script tree onto the payment origin.

This is a **cheap decision now and an expensive one in eighteen months.** It should be taken before Phase 3 (Pay-in) begins.

---

## 5. NEW ARTIFACTS RAYVAANAH MUST PRODUCE

The supplement surfaces obligations under Requirements 12.9.1 and 12.9.2 that have **no corresponding artifact in Deliverables 1–9**. These are TPSP obligations that arrive with the business model chosen in Stage 1.

| # | Artifact | Driver | Why it doesn't exist yet | Owner |
|---|---|---|---|---|
| A1 | **Written merchant agreement clause** acknowledging Rayvaanah's responsibility for the security of account data it possesses, stores, processes or transmits, or that it could affect | Req. 12.9.1 | Merchant agreement drafted commercially, not against PCI TPSP obligations | Legal + Compliance |
| A2 | **PCI DSS Responsibility Matrix** — per requirement, stating whether it is Rayvaanah's, the merchant's, or shared; explicitly covering how each party addresses 6.4.3 and 11.6.1 | Req. 12.9.2 | Not contemplated in D1–D9 | Compliance + CTO |
| A3 | **Script inventory with written business/technical justification**, per payment page | Req. 6.4.3 | No inventory mechanism in the build | CTO |
| A4 | **Change- and tamper-detection mechanism** evaluating headers and scripts as received by the browser | Req. 11.6.1 | Not in the D8 infrastructure architecture | CTO + DevOps |
| A5 | **Targeted Risk Analysis under 12.3.1**, if operating at any frequency other than weekly | Req. 11.6.1 | No TRA framework exists | Compliance |
| A6 | **Incident response plan section** covering monitoring and response to alerts from the payment-page tamper-detection mechanism | Req. 12.10.5 | Stage 7 policy package not yet drafted | Compliance |
| A7 | **Merchant integration guide** stating which flow yields which merchant responsibility, and how to implement Rayvaanah's solution securely | Supplement, TPSP best practice | Developer portal docs not written | Product + Compliance |

**A2 is the one with commercial consequence.** Merchants will ask for it during their own assessments, and enterprise merchants and sponsor PAs will ask for it during due diligence. Not having it is a visible gap. Having a clear, well-drafted one is a differentiator against competitors who hand over a vague AOC and nothing else.

**Note on A1/A2 scope:** a provider whose only service is supplying scripts unrelated to payment processing, where those scripts cannot affect the security of account data, is not a TPSP for the purposes of 12.8 and 12.9. That carve-out does not help Rayvaanah — payment processing is precisely the service.

---

## 6. CONTROLS TO BUILD

The supplement is explicit that PCI DSS does not mandate any particular mechanism. Entities choose, and combine. What follows is a recommendation, not a requirement.

### Requirement 6.4.3

| Element | Recommended control | Implementation note |
|---|---|---|
| **Authorization** | Script inventory as versioned config in the repo, changes requiring PR approval by a named owner | Authorisation may occur before a script is added or changed, or as soon as practicable after — third-party scripts can change without notice, and the guidance accommodates that |
| **Integrity** | SRI for static first-party scripts; CSP with hashes or nonces; behaviour monitoring for anything dynamic | SRI is straightforward for static scripts and impractical for rapidly changing ones. It also **fails silently** — no native alerting — so it cannot stand alone |
| **Inventory + justification** | Inventory file in the checkout repo, validated in CI/CD; build fails on any script not on the list | Integrating inventory into CI/CD is called out directly. It is also the cheapest option given an existing pipeline |

### Requirement 11.6.1

| Element | Recommended control |
|---|---|
| **Detect changes to security-impacting headers** | Agentless synthetic monitoring — a headless browser walking the checkout flow, capturing CSP, X-Frame-Options, HSTS, Referrer-Policy, Permissions-Policy, Set-Cookie and the cross-origin policy headers, diffed against baseline |
| **Detect script content changes** | Same synthetic run, hashing every loaded script and diffing against the authorised inventory |
| **Detect indicators of compromise** | CSP `report-to` / `report-uri` violation reporting piped into the SIEM; alert on any call to a non-allow-listed domain |
| **Frequency** | **Start at continuous or daily, not weekly.** Weekly is the floor, and the guidance itself notes that malicious modifications can persist undetected between runs |
| **Alert routing** | Into the existing notification/worker infrastructure, then to a named on-call owner, then into the IR plan (A6) |

### Why not CSP alone

CSP is browser-native and widely supported, and it is not sufficient on its own. It cannot generate a list of unauthorised scripts, cannot alert on changes to security-impacting headers, maintains no baseline of normal activity across sessions, and cannot detect deletion of a security header or an internal behavioural change in an already-authorised script unless that script calls a disallowed domain.

**CSP plus synthetic monitoring plus CI/CD-enforced inventory** covers all elements of both requirements. That combination is buildable with the team and pipeline already in place — no commercial e-skimming product is strictly necessary, though one may be cheaper than building and operating the synthetic monitor.

### Validation route note

**Entities completing an SAQ are not eligible to use the customized approach.** If Rayvaanah wants the flexibility of meeting a Customized Approach Objective rather than the requirement as literally stated, it must have a QSA or ISA assess and document in a ROC. This is a decision to take with the sponsor and acquirer early, not at assessment time.

---

## 7. WHAT THIS MEANS FOR THE BUILD

| # | Change | Phase affected | Urgency |
|---|---|---|---|
| C1 | Hosted checkout as a separate origin/app, never a portal SPA view | **Phase 3 (Pay-in) — not yet started** | **Decide before Phase 3 opens** |
| C2 | Zero-third-party-script policy on the checkout origin, enforced in CI | Phase 3 | Same |
| C3 | Script inventory file + CI validation gate | Phase 3 / Phase 8 hardening | High |
| C4 | Synthetic tamper-detection worker in the existing worker infrastructure | Phase 8 hardening | Medium |
| C5 | CSP with reporting on checkout origin; header baseline captured | Phase 3 | High |
| C6 | Payment-link flow designed as genuinely out-of-band (fully outsourced), and documented as such | Phase 3 | High — this is the merchant value proposition |
| C7 | Responsibility matrix (A2) drafted alongside the merchant agreement | Parallel to Phase 3 | High — sponsor due diligence will ask |
| C8 | Alert handling added to the IR plan | Stage 7 | Medium |

**None of this blocks the current phase.** Phases 0, 1 and 4 are complete and unaffected. C1 and C6 are the two decisions that get materially more expensive after Phase 3 begins.

---

## 8. EVIDENCE REGISTER — WHAT AN ASSESSOR WILL ASK FOR

Build the evidence habit into the pipeline now, so the first assessment is a review of a working programme rather than a reconstruction.

| Requirement | Evidence expected |
|---|---|
| **6.1.1** | Documented policies and procedures for managing payment page scripts; evidence they are kept current; personnel available to confirm they are in use and known |
| **6.1.2** | Documented, assigned roles and responsibilities for 6.4.3 activities; personnel who can confirm they understand them |
| **6.4.3** | Script inventory records; written technical or business justification per script; system configurations showing the authorisation method and the integrity method; personnel interviews |
| **11.1.2** | Documented, assigned roles and responsibilities for 11.6.1 activities |
| **11.6.1** | System settings for the detection mechanism; the list of monitored payment pages; monitoring output (logs, reports); configuration proving it evaluates both headers and page scripts; configuration proving the frequency; the TRA if not weekly; personnel interviews |
| **12.10.5** | IR plan detailing monitoring and response for alerts from the payment-page tamper-detection mechanism; an opportunity to observe the process — a tabletop exercise suffices where there have been no real incidents |

Authorisation records can be as simple as workflow or ticketing entries, or retained email approvals. Inventory can be a spreadsheet, a document, a database, or a page in a CMS. **The bar is documented and operating, not expensive.**

---

## MODULE CLOSE

### DECISIONS

| # | Decision | Basis | Status |
|---|---|---|---|
| D2A.1 | 6.4.3 and 11.6.1 are in scope for Rayvaanah in every payment-page scenario it serves as TPSP | Supplement Table 3 | **Settled** |
| D2A.2 | Hosted checkout to be a separate origin and application, never a view in the portal SPA | SPA scoping guidance | **Recommended — needs CTO sign-off before Phase 3** |
| D2A.3 | Payment links to be designed as genuinely out-of-band, to qualify merchants for the fully-outsourced position | Supplement Table 3 | **Recommended** |
| D2A.4 | Control stack = CSP + synthetic browser monitoring + CI-enforced script inventory | Supplement §Controls; CSP limitations | **Recommended** |
| D2A.5 | Detection frequency to start at daily or continuous, not the weekly floor | Supplement frequency guidance | **Recommended** |
| D2A.6 | Absorbing merchant-side payment page burden is a priced product feature, not an accident | §2 | **PENDING — commercial decision** |

### OPEN QUESTIONS

| # | Question | Answered by | Blocks |
|---|---|---|---|
| Q2A.1 | Is card acceptance in scope, and at what horizon? | Ayushmaan | Whether this module is now or later |
| Q2A.2 | Does Rayvaanah validate via SAQ D for Service Providers or a ROC? | Sponsor PA / acquirer / payment brand | Customized approach eligibility; assessment cost |
| Q2A.3 | Will any payment-capture surface be rendered inside the merchant portal or admin console? | CTO + Product | D2A.2 — and the size of the scope |
| Q2A.4 | Build the synthetic monitor, or buy an e-skimming product? | CTO | Phase 8 budget |
| Q2A.5 | **Still open from Stage 1:** what does the existing PCI AOC actually cover? | Issuing QSA/ISA | The rest of Stage 2 |

### RISKS

| # | Risk | Severity | Mitigation |
|---|---|---|---|
| R2A.1 | Payment capture lands inside the portal SPA and drags every view and third-party script into scope | **HIGH** | D2A.2, decided before Phase 3 |
| R2A.2 | Merchant collateral claims iframes or redirects remove merchant burden entirely — they don't | **MEDIUM-HIGH** | Correct in the integration guide (A7) before launch |
| R2A.3 | No responsibility matrix at sponsor or enterprise-merchant due diligence | **MEDIUM-HIGH** | A2, drafted in parallel with Phase 3 |
| R2A.4 | Server-side file integrity monitoring mistaken for satisfying 11.6.1 | **MEDIUM** | The control must observe what the browser receives — specify this in the build ticket |
| R2A.5 | Advisors or vendors quoting the superseded March 2025 v1.0 redirection guidance | **LOW-MEDIUM** | Require Rev 1, April 2025 |

### NEXT ACTIONS

1. **CTO** — take D2A.2 and D2A.3 now; both are cheap today and expensive after Phase 3 opens
2. **Product** — answer Q2A.3 definitively and record it as an architectural constraint, not a preference
3. **Compliance** — begin A2 (responsibility matrix) in parallel; sponsor due diligence will ask for it
4. **Ayushmaan** — answer Q2A.1 (card horizon), which sets the urgency of this whole module
5. **Compliance** — **retrieve the PCI AOC scope statement (Q2A.5)**, still the single gating input for the rest of Stage 2

---

## SOURCE REGISTER — ADDITIONS

| # | Document | Reference | Date | Status |
|---|---|---|---|---|
| S14 | PCI SSC, *Information Supplement: Payment Page Security and Preventing E-Skimming — Guidance for PCI DSS Requirements 6.4.3 and 11.6.1* | Version 1.0, Revision 1 | April 2025 | **Guidance, not a requirement.** Interprets mandatory requirements 6.4.3 and 11.6.1 |
| S15 | PCI DSS v4.0.1, §4 Scope of PCI DSS Requirements | — | Jun 2024 | CDE definition, including components that could impact CHD/SAD security |
| S16 | PCI DSS v4.0.1, Appendices B, C (compensating controls), D (customized approach), G (glossary) | — | Jun 2024 | Referenced for alternative compliance routes |
| S17 | PCI SSC, *Information Supplement: Best Practices for Securing E-commerce* | — | — | **Not yet obtained** — recommended for Stage 2 completion |

---

**PREPARED BY:** Rayvaanah Headquarters — Financial Systems Division
**REVIEW STATUS:** Stage 2, Module A of 10 — complete. Stage 2 Modules B (CDE scope) and C (Architectures A–E comparison) pending Q2A.5.
**NEXT DOCUMENT:** Stage 2, Module B — Cardholder Data Environment Scope Determination
