# RAYVAANAH STRATEGIC DOCUMENT

**Prepared for:** Ayushmaan Chandra
**Organization:** Rayvaanah — Financial Systems Division
**Document:** Stage 1 — Regulatory Classification & Business Model Analysis
**Date:** 17 August 2026
**Classification:** Internal / Advisor-Restricted
**Status:** **PRELIMINARY ASSESSMENT — REQUIRES PROFESSIONAL AND LEGAL CONFIRMATION**

---

## STAGE 1 — OPENING FRAME

### What we are determining

Whether Rayvaanah, as currently designed, is a **technology provider** or a **regulated payment entity** — and therefore whether the platform being built (schema.sql, openapi.yaml, the ledger/settlement/payout modules already coded) can lawfully be operated by Rayvaanah itself, or must be operated on behalf of an authorised party.

Every subsequent stage inherits this answer. PCI scope, escrow design, ledger ownership, payout API semantics, capital requirement, audit obligations and go-live date are all downstream of it.

### Why it matters

The regulatory perimeter in Indian payments is drawn around **fund handling**, not around technology sophistication. A platform can be architecturally identical on both sides of that line and be legal on one side and unauthorised on the other. The distinguishing fact is not what the software does — it is **whose money moves through whose account**.

Getting this wrong is not a compliance finding to be remediated later. It is an authorisation issue that can require winding up the activity.

### Assumptions being used

| # | Assumption | Source | If wrong |
|---|---|---|---|
| A1 | Rayvaanah Ventures Pvt Ltd is an Indian company under the Companies Act, 2013 | Prior project record | Changes eligibility entirely |
| A2 | Rayvaanah does **not** currently hold an RBI Certificate of Authorisation (CoA) as a Payment Aggregator | Stated business context ("do not assume I am already a licensed PA") | Model B below becomes immediately available |
| A3 | The SBI / Yes Bank escrow arrangements are **bank-offered accounts**, not an RBI authorisation | Stated business context | — (this assumption is the crux; see §2) |
| A4 | Merchants are third parties, not Rayvaanah group entities | Platform blueprint | Group-only flows change the analysis materially |
| A5 | Domestic INR only at launch; no cross-border pay-in/payout in scope | Not stated — **assumed** | PA–CB regime and FEMA obligations attach |
| A6 | Target merchants are Indian entities selling goods/services (not lending, insurance, or securities distribution) | Prior project record | SEBI / IRDAI / RBI lending overlays attach |
| A7 | Existing "PCI DSS approval and ISO certification" refers to certification of Rayvaanah's own environment | Prior project record | Scope of that AOC must be verified — see Stage 2 |

**A5 and A7 are flagged as material unconfirmed assumptions.** A5 changes the licence category; A7 changes Stage 2 entirely.

### What must be confirmed externally before Stage 1 becomes final

1. **The precise legal character of the SBI and Yes Bank arrangements** — escrow, nodal, collection, or ordinary current account; account title-holder; permitted debits as written in the mandate. *Confirm with: SBI and Yes Bank relationship teams; obtain the executed account agreement.*
2. **Whether Rayvaanah's Memorandum of Association covers PA activity.** *Confirm with: company secretary / legal counsel.* (Required by Direction 5(c).)
3. **Rayvaanah's audited net worth as at the most recent balance sheet date**, computed per RBI's net-worth methodology. *Confirm with: statutory auditor.*
4. **Whether any RBI authorisation application is already pending** for the group. *Confirm with: legal counsel / RBI PRAVAAH portal record.*
5. **The scope statement on the existing PCI DSS Attestation of Compliance** — which entity, which environment, which SAQ/ROC, which date. *Confirm with: the QSA or ISA who issued it.*

---

## 1. OVERVIEW

Rayvaanah is building an end-to-end payment infrastructure platform spanning merchant onboarding, collections, escrow ledgering, payouts, settlement and reconciliation, with escrow arrangements at two scheduled commercial banks.

As of **15 September 2025**, the regulatory framework governing exactly this activity was replaced in full. The **Reserve Bank of India (Regulation of Payment Aggregators) Directions, 2025** repealed the 2020 and 2021 PA/PG Guidelines and the 2023 Cross-Border PA framework, and consolidated online, physical and cross-border aggregation into a single code. Any analysis, advisory memo, vendor proposal or internal document written before that date is now unreliable on this subject.

The 2025 Directions did three things that bear directly on Rayvaanah:

1. They **restated the PA definition around a two-limb activity test** (aggregate + settle), removing much of the ambiguity previous entrants relied on.
2. They **explicitly placed the escrow account inside the authorisation perimeter** — the escrow is a consequence of being authorised, not an alternative to it.
3. They **raised the capital floor** to ₹15 crore at application and ₹25 crore by the end of the third financial year post-authorisation.

This document assesses Rayvaanah against that test, activity by activity, and sets out three viable structures.

---

## 2. STRATEGIC INSIGHT

> **The escrow account is not a permission. It is a consequence of one.**

This is the single most important finding in Stage 1, and it inverts the assumption on which the current build has proceeded.

The intuition that "we have escrow arrangements with SBI and Yes Bank, therefore we are permitted to hold and settle merchant funds" is the reverse of how the Directions are constructed. Under **Direction 16(a)**:

> A non-bank PA shall maintain the funds collected on behalf of its merchants in a separate escrow account with any Scheduled Commercial Bank in India… **Such escrow accounts shall only be utilised for authorised PA business and not for any other business.**

Three consequences follow, and each one cuts:

**First — the escrow presupposes authorisation.** The account exists *because* an entity is an authorised PA, to ring-fence funds it is already permitted to collect. It does not create the permission to collect them. The Directions make this explicit in the timelines row of Table 1: a PA may migrate funds to an escrow account prior to authorisation, but **the protection under Direction 16(b) is available only after authorisation.** A pre-authorisation escrow is a bank product with no statutory protection.

**Second — "and not for any other business" forecloses the payout model.** The intended design routes both collections *and* disbursements through the escrow. Direction 16(a) confines the escrow to authorised PA business, and Table 1 sets out permitted credits and debits as a **closed list**. Merchant/vendor payouts to arbitrary beneficiaries do not appear on it. The only third-party debit permitted is narrow and conditional: payment to a third party on a merchant's specific direction, where the merchant has annual turnover above ₹40 lakh (or export turnover above ₹5 lakh) **and** the third party is the payee that actually interfaces with the payer for the underlying transaction. That is a settlement mechanic, not a payout business.

**Third — the bank is now a policing party, not just a service provider.** Direction 18(a) requires the PA to submit its merchant list to the escrow bank and update it before initiating settlement, and requires an exclusive clause in the PA–bank agreement restricting the account to permitted debits and credits. **The bank shall ensure that payments are made only to eligible merchants and for permissible debits or credits.** SBI and Yes Bank are therefore obliged to constrain the account in a way that is incompatible with an unauthorised operator running general collections and payouts through it.

**The strategic reading:** the escrow arrangements are an asset — but they are an asset that only converts to value inside one of the three structures in §8. Treating them as a licence substitute is the highest-severity risk on this engagement.

---

## 3. FINANCIAL / PAYMENT CONTEXT — WHERE THE PERIMETER SITS

### 3.1 The two definitions that decide everything

**Payment Aggregator — Direction 4(i):**

> An entity that facilitates aggregation of payments made by customers to the merchants through one or more payment channels through the merchant's interface (physical / virtual) for purchase of goods, services or investment products, **and subsequently settles the collected funds to such merchants.**

This is a **two-limb conjunctive test**:

- **Limb 1 — aggregation.** Facilitating customer→merchant payments through the merchant's interface.
- **Limb 2 — settlement of collected funds.** Receiving the funds and subsequently settling them to the merchant.

Both limbs must be present. An entity that does Limb 1 without Limb 2 is not a PA. An entity that does both is a PA regardless of what it calls itself, what its contracts say, or how sophisticated its technology is. **Nomenclature is not a defence; the activity test governs.**

**Payment Gateway — Direction 4(j):**

> An entity that provides technology infrastructure to route and facilitate processing of a payment transaction **without any involvement in handling of funds.**

And critically, **Direction 10(g):**

> A PG, as defined in paragraph 4(j), shall not fall within the scope of this MD. However, a PG is encouraged to adopt the baseline technology recommendations of the Reserve Bank of India (appended as Annexure 1).

### 3.2 The single discriminating question

> **Do funds belonging to third parties enter an account in Rayvaanah's name, or under Rayvaanah's operational control, at any point between the payer and the merchant?**

- **Yes** → Limb 2 is satisfied. If Limb 1 is also satisfied, this is PA activity, and **Direction 5(b)** requires RBI authorisation for a non-bank entity.
- **No** → Rayvaanah sits outside the PA perimeter as a PG / Technology Service Provider, and Direction 10(g) applies.

There is no third answer, and no partial answer. "The funds are in escrow, so they aren't really ours" does not survive the test — an escrow held in the PA's own name for merchant funds is precisely the arrangement Direction 16(a) contemplates *for an authorised PA*.

### 3.3 What "Technology Service Provider" actually means in Indian regulation

TSP is **not a regulatory category**. There is no RBI TSP licence, registration, or recognition. It is a commercial description of an unregulated vendor.

TSPs acquire binding obligations by **contractual and supervisory flow-down**, not by direct regulation:

- **Framework for Outsourcing of Payment and Settlement-related Activities by Payment System Operators** (3 August 2021) — expressly captures IT-based services and customer onboarding within its scope, and applies to vendors, payment gateways, agents, consultants and sub-contractors, whether or not located in India. Notably, RBI's outsourcing instructions to banks and NBFCs carve out technology matters; **this framework does not.**
- **Cyber Resilience and Digital Payment Security Controls for non-bank PSOs Master Directions, 2024** (30 July 2024) — applies directly to *authorised* non-bank PSOs, but requires those PSOs to **ensure adherence by unregulated entities in their ecosystem**, naming payment gateways, third-party service providers and vendors.

So the TSP route reduces *direct* regulatory exposure to near zero, while transferring a substantial and enforceable control burden into commercial contracts. **This is a genuine reduction in regulatory risk. It is not a reduction in security or engineering work.**

### 3.4 The provision that constrains Rayvaanah's compliance engine

This deserves separate emphasis because it directly contradicts part of the architecture already designed (Deliverable 3).

**Outsourcing Framework, paragraph 2.1:**

> The PSOs shall not outsource core management functions, including risk management and internal audit; **compliance and decision-making functions such as determining compliance with KYC norms.**

Reinforced by **PA Direction 15(c):**

> The ultimate responsibility of due diligence shall lie on PA and agents can only be used for limited purposes as prescribed above.

Direction 15(a) permits a non-bank PA to use agents only for two things: the digital KYC process, and assisted V-CIP.

**Implication for the build:** if Rayvaanah operates as a TSP to a licensed PA, its risk-scoring and compliance modules must be **decision-support**, not decision-making. The system may compute a score, assemble evidence, surface exceptions and route a case. **The approve/reject decision must be taken by a named officer of the regulated entity**, and the audit trail must show that.

The good news: the onboarding state machine already shipped in Phase 1 admits **no SYSTEM actor into APPROVED / REJECTED / EDD_REQUIRED**. That design choice — made for internal integrity reasons — turns out to be the exact control this provision requires. It should now be documented as a regulatory control, not merely an engineering one.

### 3.5 The payout question — a separate and under-appreciated problem

**The PA Directions do not regulate payouts.** They govern the flow *from customers to merchants*. Disbursing funds *from* a merchant *to* vendors, employees or beneficiaries is a different activity, outside this Master Direction entirely.

That is not a gap Rayvaanah can occupy. It is an activity for which **there is no non-bank authorisation category at all**. Payout businesses in India generally operate in one of three ways: (a) as a bank's corporate customer moving its **own** funds via bulk payment APIs; (b) as a technology layer over a **bank's** disbursement product, where the bank debits the merchant's own account; or (c) inside a licensed structure (bank, PPI issuer for specified use cases).

Two constraints close off the pooled-account model that many platforms historically used:

1. **Direction 16(a)** — the PA escrow may not be used for any other business.
2. **The current/transaction account framework.** RBI amendments issued in December 2025, effective 1 April 2026, provide that accounts must not be used as pass-through channels for third-party transactions unless the entity is expressly licensed by a financial sector regulator to do so, and that **banks shall ensure accountholders not licensed or authorised by RBI to accept deposits or provide payment services do not engage in such activities through their accounts.** Banks are required to flag and monitor accounts showing frequent pass-through activity or transaction patterns inconsistent with the accountholder's stated line of business.

> **This requires confirmation from legal counsel and from SBI/Yes Bank**, because I am relying on the amendment as reported and on the draft text that preceded it; the exact final wording of the operative chapter must be read before it is relied upon. The direction of travel, however, is unambiguous and is consistent across the draft and final instruments.

**Assessment:** a payout product where third-party funds pool in a Rayvaanah-held account and are disbursed to beneficiaries has **no clear lawful basis for an unauthorised non-bank**, and the account rules taking effect from 1 April 2026 are specifically designed to detect and stop it. Payout must be re-architected as **bank-rails-with-merchant-debit**, not **Rayvaanah-pool-with-Rayvaanah-debit**.

---

## 4. SYSTEM ARCHITECTURE / FLOW — LAYERED RESPONSIBILITY MAP

```
LAYER 0   CUSTOMER / PAYER
          Rights: chargeback, refund to original instrument (Dir. 10(f)),
          TAT protection on failed transactions, grievance redressal
                    │
LAYER 1   ISSUING BANK / NPCI / CARD NETWORK
          Owns: authentication, transaction limits (Dir. 10(d)), issuer risk,
          clearing. NOT Rayvaanah's responsibility — and Dir. 10(d) forbids a
          PA from imposing per-mode transaction limits
                    │
LAYER 2   ACQUIRING BANK / PSP BANK
          Owns: merchant acquiring policy for PA-acquired merchants (Dir. 14(a)),
          ability to obtain merchant DD records on demand (Dir. 14(b)),
          card scheme compliance, settlement into escrow
                    │
LAYER 3   AUTHORISED PAYMENT AGGREGATOR  ◄── THE REGULATED PERIMETER
          Owns: merchant CDD via CKYCR (Dir. 13(a)), FIU-IND registration
          (Dir. 13(i)), MCC/MID allotment (Dir. 13(e)), escrow operation
          (Dir. 16), Board-approved IS policy (Dir. 9(b)), annual CERT-In
          empanelled system + cyber audit (Dir. 9(d)), dispute framework
          (Dir. 8), grievance officer (Dir. 8(d)), RBI reporting (Annexure 2),
          ₹15cr → ₹25cr net worth (Dir. 6)
          ══════════ ↕ funds cross this line, obligations do not delegate ══════
LAYER 4   PAYMENT GATEWAY / TSP  ◄── WHERE RAYVAANAH SITS IN MODEL A
          Owns: routing, orchestration, APIs, ledgering-as-record,
          reconciliation compute, dashboards, webhooks, developer portal,
          decision-SUPPORT for onboarding and risk.
          Bound by: contract + Outsourcing Framework flow-down + Cyber
          Resilience MD flow-down + Annexure 1 baseline (recommended for PG)
          Does NOT own: fund custody, the compliance decision, the CoA
                    │
LAYER 5   MERCHANT
          Owns: goods/services, its own PCI-DSS posture where it touches card
          data, its own bank account as the only permitted settlement
          destination (Dir. 13(g))
```

**The line to internalise is between Layers 3 and 4.** Funds and non-delegable obligations sit above it. Technology sits below it. Rayvaanah's platform is a Layer 4 asset that has been designed to also perform Layer 3 functions. Stage 3 will resolve how to split it.

---

## 5. KEY COMPONENTS / PLAYERS — ACTIVITY CLASSIFICATION MATRIX

**Reading note:** "Who performs it" shows the position under **Model A (TSP/PG)** — the lowest-risk structure — followed in brackets by who performs it if Rayvaanah becomes an **authorised PA (Model B)**. "RBI authorisation potentially required?" refers to whether *Rayvaanah* performing that activity for itself would trigger the requirement.

| # | Activity | Who performs it (Model A → Model B) | Regulatory category | RBI authorisation potentially required? | PCI DSS relevance | Major risk |
|---|---|---|---|---|---|---|
| 1 | **Escrow account operation** | Licensed PA + SCB → Rayvaanah + SCB | PA activity, Dir. 16 & 18 | **YES — direct trigger.** Escrow confined to authorised PA business | Indirect (no CHD) | **CRITICAL.** Operating without CoA = unauthorised payment system activity |
| 2 | **Receiving customer funds** | Licensed PA → Rayvaanah | PA activity, Dir. 4(i) Limb 2 | **YES — direct trigger** | Indirect | **CRITICAL.** Definitional trigger for the whole regime |
| 3 | **Holding funds (float)** | Licensed PA → Rayvaanah | PA activity, Dir. 16, 17 | **YES** | Indirect | **CRITICAL.** Also engages NDTL treatment at the bank; core-portion interest only after 26 fortnights + audited year |
| 4 | **Merchant collections** | Licensed PA → Rayvaanah | PA activity, Dir. 4(i) both limbs | **YES** | **HIGH** if card data traverses Rayvaanah | **CRITICAL** |
| 5 | **Payment processing** | PA / acquirer / processor → same | Mixed; PG portion is Dir. 4(j) | Depends entirely on fund handling | **HIGH** for card rails | HIGH — scope creep from "processing" into "handling" |
| 6 | **Payment aggregation** | Licensed PA only → Rayvaanah | PA activity, Dir. 4(i) | **YES — the defining activity** | Medium | **CRITICAL** |
| 7 | **Payment gateway functionality** | **Rayvaanah** → Rayvaanah | PG, Dir. 4(j) — **out of scope per Dir. 10(g)** | **NO** | **HIGH** — architecture-dependent (Stage 2) | MEDIUM. Safe only while no funds are handled |
| 8 | **Card processing** | Acquirer / PA / processor → PA + processor | PA + card scheme rules | Depends on fund handling | **HIGHEST.** Dir. 9(a) requires PCI-DSS/PA-DSS posture; Annexure 1 §2.1 bars card credentials in merchant-accessible DB/server | **CRITICAL.** Largest PCI scope driver |
| 9 | **UPI processing** | PSP bank + NPCI → same | NPCI/UPI framework, separate from PA CoA | **NO for Rayvaanah**, but NPCI/PSP-bank approval is required | Low (no card data) | HIGH — NPCI TPAP/PSP arrangements must be confirmed separately |
| 10 | **Virtual accounts** | Sponsor bank → sponsor bank | Bank product; VA is the bank's, not Rayvaanah's | **NO** (bank product) — but reconciliation logic is Rayvaanah's | Low | HIGH. VAs that collect third-party funds into a Rayvaanah-controlled pool re-trigger #2 |
| 11 | **Payouts / disbursement** | **Bank rails, merchant-account debit** → same | **No non-bank authorisation category exists** | **N/A — no licence available.** Must ride bank product | Low | **CRITICAL.** Pooled-account payouts have no clear lawful basis; account rules from 1 Apr 2026 target exactly this |
| 12 | **Merchant settlement** | Licensed PA → Rayvaanah | PA activity, Dir. 16 Table 1, Dir. 13(g) | **YES** | Indirect | **CRITICAL.** Dir. 13(g) — funds to the merchant's own bank account only |
| 13 | **Refunds** | PA + acquirer → same | PA activity, Dir. 10(f), 18(h) | Follows the settlement answer | Medium | HIGH. Must route to original instrument; reversal entries mandatory |
| 14 | **Reconciliation (compute)** | **Rayvaanah** → Rayvaanah | Technology / outsourced activity | **NO** | Low | MEDIUM. Break-detection failures become the PA's regulatory failure |
| 15 | **Ledger management** | **Rayvaanah** (as record) → Rayvaanah (as record of its own liability) | Technology, unless it is the authoritative record of a PA's merchant liability | **NO** in Model A | Low | HIGH. A ledger that *directs* fund movement is closer to Layer 3 than Layer 4 |
| 16 | **Transaction routing** | **Rayvaanah** → Rayvaanah | PG, Dir. 4(j) | **NO** | Medium | LOW |
| 17 | **API orchestration** | **Rayvaanah** → Rayvaanah | PG / technology | **NO** | Medium | LOW |
| 18 | **Payment links** | **Rayvaanah** builds; PA owns the collection | PG surface over PA activity | **NO** for the interface; **YES** for the collection behind it | **HIGH** — hosted vs. embedded decides scope | MEDIUM |
| 19 | **Webhooks** | **Rayvaanah** → Rayvaanah | Technology | **NO** | Low (never carry PAN/SAD) | LOW |
| 20 | **Merchant onboarding** | **Rayvaanah** builds; PA decides | Outsourced activity; expressly in Outsourcing Framework scope | **NO**, subject to §3.4 | Medium (PII, not CHD) | **HIGH.** Dir. 15(c) — ultimate DD responsibility cannot be delegated |
| 21 | **KYC / CDD** | PA performs; **Rayvaanah** may assist per Dir. 15(a) | **Non-delegable** decision. CKYCR retrieval mandatory (Dir. 13(a)) | **NO** for assistance; the function itself is the PA's | Medium (PII) | **CRITICAL.** Outsourcing Framework 2.1 bars outsourcing the KYC determination |
| 22 | **Fraud monitoring** | **Rayvaanah** detects; PA decides & reports | Dir. 9 + Cyber Resilience MD, flowed down | **NO** for detection | Medium | HIGH. Risk management is a core management function — cannot be outsourced as decision |

### Pattern in the matrix

Rows **1, 2, 3, 4, 6, 12** are the perimeter. They are the same activity described six ways: **taking custody of somebody else's money and paying it onward.**

Rows **7, 14, 15, 16, 17, 19** — the largest part of what has actually been built — sit cleanly outside the perimeter.

Rows **20, 21, 22** are the subtle ones: the software may do the work, but the **decision** must belong to a regulated entity.

Row **11** is the outlier that needs its own answer, because no licence category exists to solve it.

---

## 6. REVENUE MODEL / MONETIZATION IMPLICATIONS

The prior CRO provisioning model assumes standard PayIn 2% / PayOut 2.5% merchant pricing. That is **PA economics** — the margin of an entity that owns the merchant relationship and the fund flow. It is not available to a Layer 4 entity.

| Structure | What Rayvaanah can charge for | Realistic economics | Capital required | Time to first live merchant |
|---|---|---|---|---|
| **Model A — TSP / PG** | Platform licence, per-transaction technology fee, setup/integration, per-verification pass-through, SaaS tiers for the console | Technology-fee economics. Materially thinner per transaction than MDR-based pricing, but **recurring, capital-light and not capacity-constrained by net worth** | Working capital only | Shortest — gated by partner integration, not by RBI |
| **Model B — Authorised PA** | Full MDR-based PayIn/PayOut spread on own book | The 2%/2.5% model as originally modelled | **₹15 cr at application; ₹25 cr by end of FY3**, maintained on an ongoing basis | Longest — application, fit-and-proper, auditor certification, RBI decision |
| **Model C — Hybrid** | Technology fee now; revenue share with the sponsor PA; MDR economics later on conversion | Blended; improves as volume proves the book | ₹15 cr only at the point of application | Short to revenue, long to full economics |

**Strategic observation:** Model A is not a lesser business. A licensed PA's largest recurring cost is precisely the technology stack Rayvaanah has already built — nine deliverables, a schema, an OpenAPI spec, a working ledger with invariant tests. **There are more than thirty authorised PAs in India and several dozen more with applications pending, and most of them are carrying build or vendor costs for exactly this.** Selling infrastructure to the regulated layer is a defensible business that requires no CoA and no ₹25 crore.

Model B is not foreclosed. It is a **capital and calendar** decision, not a capability one — and one that is materially easier to make after the platform is running live volume under a sponsor.

---

## 7. RISK & COMPLIANCE LAYER — WHAT BINDS RAYVAANAH EVEN AS A TSP

The most common error at this point is to conclude that the TSP route removes the compliance programme. It does not. It changes **who enforces it** from RBI to a counterparty with contractual audit rights and its own licence at risk.

| Instrument | Applies to Rayvaanah directly? | Applies via flow-down? | Nature |
|---|---|---|---|
| **PA Directions, 2025 (Dir. 10(g))** | **No** — a PG is outside scope | Yes, through PA contract | Legal (to the PA) / Contractual (to Rayvaanah) |
| **PA Directions Annexure 1** — baseline technology recommendations | Mandatory for PAs; **encouraged** for PGs (Dir. 10(g)) | Yes, PAs will impose it | **Best practice** for a PG — do not present as law |
| **Outsourcing Framework, 3 Aug 2021** | No | **Yes — directly designed for this** | Legal (to the PSO) / Contractual (to Rayvaanah). Includes right-to-audit, RBI access, no co-mingling across PSOs, breach notification |
| **Cyber Resilience MD for non-bank PSOs, 30 Jul 2024** | No — applies to *authorised* non-bank PSOs | **Yes — expressly** ("PSOs shall ensure adherence by such unregulated entities") | Contractual. Phased for PSOs: large 1 Apr 2025, medium 1 Apr 2026, small 1 Apr 2028 |
| **Storage of Payment System Data, 6 Apr 2018** | No | Yes — Outsourcing Framework requires adherence by the service provider, domestic or offshore | Contractual, and effectively binding on infrastructure design |
| **PCI DSS v4.0.1** | **Only if the CDE is Rayvaanah's** — see Stage 2 | Yes, contractually via PA and acquirer | **Not law.** Contractual card-scheme obligation |
| **CERT-In Directions, 28 Apr 2022** | **Yes — directly.** Applies to service providers, intermediaries, data centres and body corporates generally | — | **Legal**, independent of payment status. 6-hour incident reporting; log retention 180 days in India |
| **DPDP Act 2023 + DPDP Rules 2025** (G.S.R. 846(E), notified Nov 2025) | **Yes — directly**, as a Data Fiduciary | — | **Legal.** Phased over 18 months to ~May 2027. Onboarding PII, KYC documents and director data are all in scope |
| **PMLA / FIU-IND registration** | **No** in Model A — Dir. 13(i) obliges the *non-bank PA* to register | Yes, operationally | Legal (to the PA) |

**Two obligations attach to Rayvaanah today, regardless of which model is chosen:** CERT-In and DPDP. Neither is contingent on payment authorisation. Both are live now.

---

## 8. OPPORTUNITIES — THREE VIABLE STRUCTURES

### MODEL A — Pure Technology Service Provider / Payment Gateway

Rayvaanah handles **zero** third-party funds. Escrow is held by a licensed PA or bank partner in *their* name. Rayvaanah provides the orchestration, ledger-of-record, reconciliation, onboarding workflow and consoles.

- **Regulatory position:** outside the PA Directions by operation of Dir. 10(g)
- **Authorisation:** none required
- **Capital:** none prescribed
- **PCI scope:** minimised if card data never touches Rayvaanah infrastructure (Stage 2 confirms)
- **Trade-off:** thinner unit economics; dependent on a partner; the merchant relationship is contested
- **Time to revenue:** shortest

### MODEL B — Authorised Non-Bank Payment Aggregator

Rayvaanah applies for and obtains a CoA and operates its own escrow.

- **Authorisation:** required under Dir. 5(b), via RBI's online portal (PRAVAAH); MOA must cover PA activity (Dir. 5(c))
- **Capital:** ₹15 crore at application, ₹25 crore by end of FY3, maintained on an ongoing basis; statutory auditor certificate in the Annexure 2.1 format
- **Governance:** promoters and directors must meet fit-and-proper criteria (Dir. 7(a)); prior RBI approval for any change of control
- **Ongoing burden:** annual net-worth certificate, annual externally-audited IS and cyber security audit, quarterly escrow auditor's and banker's certificates, monthly transaction statistics, FIU-IND registration and reporting, CKYCR-based merchant KYC, Board-approved IS policy, grievance officer, and full Cyber Resilience MD compliance
- **Trade-off:** full economics, full control, full burden, longest runway

### MODEL C — Hybrid / Sponsored Transition ◄ **RECOMMENDED FOR ASSESSMENT**

Operate as a TSP under a sponsor PA or bank from day one. Build merchant volume and an operating track record on the sponsor's licence. Pursue Model B in parallel on a deliberate timeline once capital and volume justify it.

- **Why this fits Rayvaanah specifically:**
  1. The platform is **already built** and does not need to change materially — most of it is Layer 4 by nature
  2. It converts the ₹15 crore capital requirement from a **precondition** into a **milestone**
  3. It generates the operating history, audited accounts and merchant book that make a PA application credible rather than speculative
  4. The escrow arrangements with SBI and Yes Bank are **not wasted** — they become the structure to be activated on authorisation, and the relationships are useful in sponsor negotiations now
  5. The onboarding state machine's existing human-actor gate already satisfies the non-delegable-decision constraint

- **The specific thing to get right:** the sponsor agreement must clearly delineate roles and responsibilities as Dir. 8(b) requires, and must not leave Rayvaanah performing a Layer 3 function under a Layer 4 label. Substance governs, not drafting.

### Preliminary conclusion

> **"Based on the described model, the most likely regulatory structure is that Rayvaanah is currently designed to perform Payment Aggregator activity as defined in Direction 4(i) of the RBI (Regulation of Payment Aggregators) Directions, 2025, and would require authorisation under Direction 5(b) to operate that design in its own name. The escrow arrangements with SBI and Yes Bank do not supply that authorisation. The recommended near-term structure is Model C — operate as a Technology Service Provider / Payment Gateway under a licensed sponsor, with a deliberate, capital-gated path to Model B."**
>
> **PRELIMINARY ASSESSMENT — REQUIRES PROFESSIONAL AND LEGAL CONFIRMATION.** This is a reading of published primary sources applied to a described business model. It is not legal advice, and no reliance should be placed on it for an authorisation decision, a bank representation, or an investor disclosure until confirmed by Indian payments counsel.

---

## 9. EXECUTION PLAN — STAGE 1 DECISION PATH

| # | Action | Owner | Depends on | Target |
|---|---|---|---|---|
| 1 | Obtain and read the executed SBI and Yes Bank account agreements — account type, title-holder, permitted debits | Bank relationship + legal | — | Week 1 |
| 2 | Engage Indian payments regulatory counsel for a written classification opinion on the two-limb test | Ayushmaan | — | Week 1 |
| 3 | Statutory auditor to compute current net worth on the RBI methodology | Finance | — | Week 2 |
| 4 | Company secretary to confirm whether the MOA covers PA activity | Legal | — | Week 2 |
| 5 | Retrieve the existing PCI DSS AOC and confirm its scope statement, entity and date | Compliance | — | Week 2 |
| 6 | **Board decision on Model A / B / C** | Board | 1–4 | Week 3 |
| 7 | If Model A or C: shortlist 2–3 sponsor PAs or banks; issue an RFI covering escrow, settlement rules, DD responsibility split, audit rights | Ayushmaan | 6 | Week 4 |
| 8 | Re-architect the payout module away from a pooled-account design toward bank-rails-with-merchant-debit | CTO | 6 | Week 4–8 |
| 9 | Re-label the compliance/risk engine's decision points as decision-support with mandatory named-human approval, and document that as a regulatory control | CTO + Compliance | 6 | Week 4–6 |
| 10 | Start CERT-In and DPDP workstreams — these bind today irrespective of the model choice | Compliance | — | Immediate |
| 11 | **Proceed to Stage 2 — PCI DSS applicability and scope analysis** | — | 5, 6 | Week 3 |

---

## 10. STRATEGIC TAKEAWAYS

1. **The escrow is a consequence of authorisation, not a substitute for it.** Direction 16(a) confines it to authorised PA business and Direction 18(a) obliges the bank to police it. This is the finding that reorders the roadmap.

2. **The perimeter is drawn by one question:** does third-party money enter an account in Rayvaanah's name or under Rayvaanah's control? Everything downstream — PCI scope, capital, audit, timeline — follows from that single answer.

3. **Most of what has been built is safe.** Routing, orchestration, ledger, reconciliation, webhooks, consoles and APIs are Layer 4 by nature. Six activities out of twenty-two constitute the perimeter, and they cluster around fund custody.

4. **The payout module is the most exposed component and needs re-architecture regardless of model.** No non-bank authorisation category exists for it, the PA escrow cannot carry it, and the account framework taking effect from 1 April 2026 is specifically designed to detect it.

5. **The compliance engine must support decisions, not make them.** The Outsourcing Framework's bar on outsourcing risk management, compliance and KYC determination is explicit. Phase 1's existing human-actor gate already satisfies this — it should now be documented as the regulatory control it turns out to be.

6. **Two obligations bind Rayvaanah today under any model:** CERT-In incident reporting and the DPDP framework. Neither waits for the licence question to resolve.

7. **Model C converts the capital requirement from a wall into a milestone** — and does so without discarding the escrow relationships, the platform, or the ambition. It is the structure that preserves optionality at the lowest cost.

---

# STAGE 1 — CLOSE

## DECISIONS

| # | Decision | Basis | Status |
|---|---|---|---|
| D1.1 | The applicable framework is the RBI (Regulation of Payment Aggregators) Directions, 2025 — all pre-15 Sep 2025 analysis is superseded | Annexure 3 repeal list | **Settled** |
| D1.2 | Classification turns on the two-limb test in Dir. 4(i), not on self-description | Dir. 4(i), 4(j), 10(g) | **Settled** |
| D1.3 | The escrow arrangements do not confer permission to aggregate or settle | Dir. 16(a), Table 1 timelines row | **Settled** |
| D1.4 | "TSP" is not a regulatory category; obligations attach by contractual flow-down | Outsourcing Framework; Cyber Resilience MD | **Settled** |
| D1.5 | The compliance/risk engine must be decision-support with a named human approver | Outsourcing Framework 2.1; PA Dir. 15(c) | **Settled — build already conforms** |
| D1.6 | Model A / B / C selection | — | **PENDING BOARD DECISION** |
| D1.7 | Payout architecture must move off any pooled-account design | Dir. 16(a); account framework eff. 1 Apr 2026 | **Recommended, pending D1.6** |

## OPEN QUESTIONS

| # | Question | Must be answered by | Blocks |
|---|---|---|---|
| Q1.1 | What is the exact legal character and title-holder of the SBI and Yes Bank accounts? | SBI / Yes Bank; legal counsel | Everything |
| Q1.2 | Does Rayvaanah satisfy the two-limb test as actually operated today? | Payments regulatory counsel | D1.6 |
| Q1.3 | What is Rayvaanah's audited net worth on the RBI methodology? | Statutory auditor | Model B feasibility |
| Q1.4 | Does the MOA cover PA activity? | Company secretary | Model B application |
| Q1.5 | What entity, environment and date does the existing PCI AOC cover? | Issuing QSA/ISA | **Stage 2** |
| Q1.6 | Is cross-border pay-in/payout in scope at any horizon? | Ayushmaan | PA–CB regime, FEMA |
| Q1.7 | What is the exact final text of the Dec 2025 current/transaction account provisions on pass-through use? | Legal counsel | Payout re-architecture |
| Q1.8 | Which UPI/NPCI arrangement is contemplated — TPAP, PSP-bank, or merchant-side only? | Ayushmaan + sponsor bank | UPI module design |

## RISKS

| # | Risk | Severity | Likelihood | Mitigation |
|---|---|---|---|---|
| R1.1 | Operating PA activity without a CoA | **CRITICAL** | High if current design goes live as-is | Do not process third-party funds in Rayvaanah's name pending D1.6 |
| R1.2 | Payout pooled-account model has no lawful basis; bank monitoring from 1 Apr 2026 targets it | **CRITICAL** | High | Re-architect to bank-rails-with-merchant-debit |
| R1.3 | Escrow used for non-PA business, breaching Dir. 16(a) | **HIGH** | Medium | Bank agreement review; restrict permitted debits in the mandate |
| R1.4 | Compliance decisions taken by the system rather than a named officer | **HIGH** | Low — build already conforms | Document the existing state-machine control as a regulatory control |
| R1.5 | Existing PCI AOC does not cover the environment now being built | **HIGH** | Medium | Q1.5, then Stage 2 |
| R1.6 | CERT-In / DPDP non-compliance while the licence question is unresolved | **MEDIUM-HIGH** | Medium | Start both workstreams now — they do not depend on D1.6 |
| R1.7 | Reliance on pre-Sept-2025 advisory material | **MEDIUM** | Medium | Re-baseline all vendor and advisor inputs against the 2025 Directions |
| R1.8 | Sponsor agreement leaves Rayvaanah performing Layer 3 functions under a Layer 4 label | **HIGH** | Medium | Counsel review of the sponsor agreement against Dir. 8(b) role delineation |

## NEXT ACTIONS

1. **Ayushmaan** — engage Indian payments regulatory counsel this week (Q1.2, Q1.7)
2. **Bank relationship** — obtain executed SBI and Yes Bank agreements (Q1.1)
3. **Finance / statutory auditor** — net worth computation on RBI methodology (Q1.3)
4. **Compliance** — retrieve the PCI AOC and its scope statement (Q1.5) — **this is the gating input for Stage 2**
5. **CTO** — freeze payout module development pending D1.6 and D1.7
6. **Compliance** — open CERT-In and DPDP workstreams immediately
7. **Board** — take D1.6 on Model A / B / C
8. **Proceed to Stage 2 — PCI DSS Applicability and Scope Analysis**, which can begin on Q1.5 alone and does not need to wait for D1.6

---

## SOURCE REGISTER

| # | Document | Reference | Date | Relevance |
|---|---|---|---|---|
| S1 | **Reserve Bank of India (Regulation of Payment Aggregators) Directions, 2025** | RBI/DPSS/2025-26/141; CO.DPSS.POLC.No.S-633/02-14-008/2025-26 | 15 Sep 2025 | Primary. Dir. 4(i), 4(j), 5, 6, 7, 8, 9, 10(g), 10(h), 13, 14, 15, 16, 17, 18; Annexures 1–3 |
| S2 | **Framework for Outsourcing of Payment and Settlement-related Activities by Payment System Operators** | CO.DPSS.POLC.No.S-384/02.32.001/2021-2022 | 3 Aug 2021 | Para 2.1 (core functions); para 9 (security, data storage, breach notice) |
| S3 | **Cyber Resilience and Digital Payment Security Controls for non-bank PSOs Master Directions, 2024** | CO.DPSS.OVRST.No.S447/06-26-002/2024-25 | 30 Jul 2024 | Applies to authorised non-bank PSOs; flow-down to unregulated entities; phased 1 Apr 2025 / 2026 / 2028 |
| S4 | **Storage of Payment System Data** | DPSS.CO.OD No.2785/06.08.005/2017-2018 | 6 Apr 2018 | Data localisation; referenced by PA Dir. 9(c) and Annexure 1 §2.3 |
| S5 | **Master Direction — Know Your Customer, 2016** (as amended) | DBR.AML.BC.No.81/14.01.001/2015-16 | 25 Feb 2016 | CDD standard invoked by PA Dir. 13; CKYCR, OVD, V-CIP definitions |
| S6 | **Master Direction on Information Technology Services** | DoS.CO.CSITEG/SEC.1/31.01.015/2023-24 | 10 Apr 2023 | Cited in PA Dir. 10(h) for PA–PG arrangements |
| S7 | **Prior approval for takeover / acquisition of control of non-bank PSOs** | CO.DPSS.POLC.No.S-590/02-14-006/2022-23 | 4 Jul 2022 | PA Dir. 7(c); applies from application stage |
| S8 | **Harmonisation of TAT for failed transactions** | DPSS.CO.PD No.629/02.01.014/2019-20 | 20 Sep 2019 | PA Dir. 8(a) dispute framework |
| S9 | **PCI DSS v4.0.1**, PCI Security Standards Council | Published 11 Jun 2024 | v4.0 retired 31 Dec 2024; 51 future-dated requirements mandatory 31 Mar 2025 | Only active version. All requirements in scope for 2026 assessments. RFC on the next version ran 3 Jun – 20 Jul 2026 |
| S10 | **Digital Personal Data Protection Rules, 2025** | G.S.R. 846(E), MeitY | Notified Nov 2025 | Phased over 18 months to ~May 2027; Rayvaanah is a Data Fiduciary today |
| S11 | **Digital Personal Data Protection Act, 2023** | Act No. 22 of 2023 | Aug 2023 | Parent statute |
| S12 | **CERT-In Directions under Section 70B(6), IT Act 2000** | No. 20(3)/2022-CERT-In | 28 Apr 2022 | 6-hour incident reporting; 180-day log retention in India. Binds Rayvaanah directly |
| S13 | **RBI current / transaction account framework amendments** | Announced 11 Dec 2025; effective 1 Apr 2026 | Dec 2025 | Pass-through restrictions; banks to ensure unlicensed accountholders do not provide payment services. **Exact final text to be verified by counsel** |

---

**PREPARED BY:** Rayvaanah Headquarters — Financial Systems Division
**REVIEW STATUS:** Stage 1 of 10 — Preliminary, pending external confirmation
**NEXT DOCUMENT:** Stage 2 — PCI DSS Applicability and Scope Analysis
