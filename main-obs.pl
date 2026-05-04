:- ['obs.pl'].

report(S, OverallStatus, Controls, GovernanceFindings, EpistemicFindings, Actions) :-
    system(S),
    sorted(control(Control, Status), controlStatus(S, Control, Status), Controls),
    sorted(finding(Type, Severity, Code), finding(S, Type, Severity, Code), Findings),
    splitFindings(Findings, GovernanceFindings, EpistemicFindings),
    overallStatus(Findings, OverallStatus),
    sorted(Action, action(S, Action), Actions).

% ---------- Helpers ----------

sorted(Template, Goal, Sorted) :- findall(Template, Goal, Results), sort(Results, Sorted).

usesPii(S) :- usesData(S, DataId), dataClass(DataId, pii).

splitFindings([finding(governance, Severity, Code) | Rest], [finding(Severity, Code) | GovernanceRest], EpistemicRest) :-
    splitFindings(Rest, GovernanceRest, EpistemicRest).
splitFindings([finding(epistemic, Severity, Code) | Rest], GovernanceRest, [finding(Severity, Code) | EpistemicRest]) :-
    splitFindings(Rest, GovernanceRest, EpistemicRest).
splitFindings([], [], []).

% ---------- Evidence model ----------

acceptableObservation(Entity, Assertion, Source, Date, Confidence) :-
    obs(Entity, Assertion, Source, Date, Confidence),
    trustedSourceFor(Source, Assertion),
    fresh(Date),
    minConfidence(Min),
    Confidence >= Min.

% ---------- Conflict model ----------

conflictingAssertion(S, owner(O1), owner(O2)) :-
    acceptableObservation(S, owner(O1), _, _, _),
    acceptableObservation(S, owner(O2), _, _, _),
    O1 @< O2.

conflictingAssertion(S, owner(O), no_owner) :-
    acceptableObservation(S, owner(O), _, _, _),
    acceptableObservation(S, no_owner, _, _, _).

conflictingAssertion(S, in_inventory, not_in_inventory) :-
    acceptableObservation(S, in_inventory, _, _, _),
    acceptableObservation(S, not_in_inventory, _, _, _).

conflictingAssertion(S, approved, not_approved) :-
    acceptableObservation(S, approved, _, _, _),
    acceptableObservation(S, not_approved, _, _, _).

conflictingAssertion(D, dataClass(C1), dataClass(C2)) :-
    acceptableObservation(D, dataClass(C1), _, _, _),
    acceptableObservation(D, dataClass(C2), _, _, _),
    C1 @< C2.

conflict(Entity, Assertion) :- conflictingAssertion(Entity, Assertion, _).
conflict(Entity, Assertion) :- conflictingAssertion(Entity, _, Assertion).


% This predicate reconstructs canonical governance facts from observations.
% A fact is accepted if it is observed by an acceptable source, is fresh,
% has sufficient confidence, and is not involved in a conflict.
accepted(Entity, Assertion) :-
    acceptableObservation(Entity, Assertion, _Source, _Date, _Confidence),
    \+ conflict(Entity, Assertion).

% ---------- Canonical views over accepted observations ----------

system(S) :- accepted(S, system).
owner(S, O) :- accepted(S, owner(O)).
noOwner(S) :- accepted(S, no_owner).
inventory(S) :- accepted(S, in_inventory).
notInInventory(S) :- accepted(S, not_in_inventory).
approved(S) :- accepted(S, approved).
notApproved(S) :- accepted(S, not_approved).
capability(S, C) :- accepted(S, capability(C)).
usesData(S, D) :- accepted(S, usesData(D)).
dataClass(D, C) :- accepted(D, dataClass(C)).
guardrail(S, G) :- accepted(S, guardrail(G)).


% ---------- Evidence-quality predicates ----------

lowConfidenceObservation(Entity, Assertion) :-
    obs(Entity, Assertion, _, _, Confidence),
    minConfidence(Min),
    Confidence < Min.
untrustedObservation(Entity, Assertion) :-
    obs(Entity, Assertion, Source, _, _),
    \+ trustedSourceFor(Source, Assertion).
staleObservation(Entity, Assertion) :-
    obs(Entity, Assertion, _, Date, _),
    \+ fresh(Date).

ownerObservation(S) :- obs(S, owner(_), _, _, _).
ownerObservation(S) :- obs(S, no_owner, _, _, _).
inventoryObservation(S) :- obs(S, in_inventory, _, _, _).
inventoryObservation(S) :- obs(S, not_in_inventory, _, _, _).
approvalObservation(S) :- obs(S, approved, _, _, _).
approvalObservation(S) :- obs(S, not_approved, _, _, _).

shadowCandidate(S) :-
    system(S),
    obs(S, system, Source, _, _),
    discoverySource(Source),
    \+ inventory(S).


% ---------- Controls ----------

controlStatus(S, owner_assigned, pass) :- system(S), owner(S, _).
controlStatus(S, owner_assigned, conflicting) :- system(S), conflict(S, owner(_)).
controlStatus(S, owner_assigned, unknown) :- system(S), \+ ownerObservation(S).
controlStatus(S, owner_assigned, unreliable) :-
    system(S),
    ownerObservation(S),
    \+ owner(S, _),
    \+ noOwner(S),
    \+ conflict(S, owner(_)).
controlStatus(S, owner_assigned, fail) :- system(S), noOwner(S).

controlStatus(S, in_inventory, pass) :- system(S), inventory(S).
controlStatus(S, in_inventory, unknown) :- system(S), \+ inventoryObservation(S).
controlStatus(S, in_inventory, unreliable) :-
    system(S),
    inventoryObservation(S),
    \+ inventory(S),
    \+ notInInventory(S).
controlStatus(S, in_inventory, fail) :- system(S), notInInventory(S).

controlStatus(S, approved, pass) :- system(S), approved(S).
controlStatus(S, approved, unknown) :- system(S), \+ approvalObservation(S).
controlStatus(S, approved, unreliable) :-
    system(S),
    approvalObservation(S),
    \+ approved(S),
    \+ notApproved(S).
controlStatus(S, approved, fail) :- system(S), notApproved(S).

controlStatus(S, pii_guardrail, not_applicable) :- system(S), \+ usesPii(S).
controlStatus(S, pii_guardrail, pass) :- system(S), usesPii(S), guardrail(S, piiFiltering).
controlStatus(S, pii_guardrail, fail) :- system(S), usesPii(S), \+ guardrail(S, piiFiltering).


% ---------- Overlap ----------

overlap(S1, S2, Capability) :-
    system(S1), system(S2), S1 @< S2,
    capability(S1, Capability), capability(S2, Capability).

overlap(S, overlaps(Other, Capability)) :- overlap(S, Other, Capability).
overlap(S, overlaps(Other, Capability)) :- overlap(Other, S, Capability).


% ---------- Governance findings ----------

finding(S, governance, high, pii_without_guardrail) :- controlStatus(S, pii_guardrail, fail).
finding(S, governance, high, shadow_ai_candidate) :- shadowCandidate(S).

finding(S, governance, medium, no_owner) :- controlStatus(S, owner_assigned, fail).
finding(S, governance, medium, not_in_inventory) :- controlStatus(S, in_inventory, fail).
finding(S, governance, medium, not_approved) :- controlStatus(S, approved, fail).

finding(S, governance, low, overlaps(Other, Capability)) :- overlap(S, overlaps(Other, Capability)).

% ---------- Epistemic findings ----------
%
% These findings do not say that the system is necessarily non-compliant.
% They say that the evidence used to reconstruct the governance state is
% incomplete, conflicting, stale, untrusted, or unreliable.

finding(S, epistemic, high, conflicting_owner_information) :- controlStatus(S, owner_assigned, conflicting).

finding(S, epistemic, medium, owner_information_unknown) :- controlStatus(S, owner_assigned, unknown).
finding(S, epistemic, medium, owner_information_unreliable) :- controlStatus(S, owner_assigned, unreliable).
finding(S, epistemic, medium, inventory_information_unknown) :- controlStatus(S, in_inventory, unknown).
finding(S, epistemic, medium, inventory_information_unreliable) :- controlStatus(S, in_inventory, unreliable).
finding(S, epistemic, medium, approval_information_unknown) :- controlStatus(S, approved, unknown).
finding(S, epistemic, medium, approval_information_unreliable) :- controlStatus(S, approved, unreliable).

finding(S, epistemic, low, low_confidence_observation(Assertion)) :-
    system(S),
    lowConfidenceObservation(S, Assertion).
finding(S, epistemic, low, untrusted_observation(Assertion)) :-
    system(S),
    untrustedObservation(S, Assertion).
finding(S, epistemic, low, stale_observation(Assertion)) :-
    system(S),
    staleObservation(S, Assertion).

% ---------- Governance actions ----------

action(S, add_pii_guardrail) :- controlStatus(S, pii_guardrail, fail).
action(S, assign_owner) :- controlStatus(S, owner_assigned, fail).
action(S, register_in_inventory) :- controlStatus(S, in_inventory, fail).
action(S, submit_for_approval) :- controlStatus(S, approved, fail).
action(S, review_consolidation) :- finding(S, governance, low, overlaps(_, _)).
action(S, investigate_shadow_ai_usage) :- finding(S, governance, high, shadow_ai_candidate).

% ---------- Evidence-quality actions ----------

action(S, resolve_owner_conflict) :- finding(S, epistemic, high, conflicting_owner_information).
action(S, request_owner_validation) :- finding(S, epistemic, medium, owner_information_unknown).
action(S, request_owner_validation) :- finding(S, epistemic, medium, owner_information_unreliable).
action(S, validate_inventory_status) :- finding(S, epistemic, medium, inventory_information_unknown).
action(S, validate_inventory_status) :- finding(S, epistemic, medium, inventory_information_unreliable).
action(S, validate_approval_status) :- finding(S, epistemic, medium, approval_information_unknown).
action(S, validate_approval_status) :- finding(S, epistemic, medium, approval_information_unreliable).
action(S, review_evidence_quality) :- finding(S, epistemic, low, low_confidence_observation(_)).
action(S, review_evidence_quality) :- finding(S, epistemic, low, untrusted_observation(_)).
action(S, review_evidence_quality) :- finding(S, epistemic, low, stale_observation(_)).

% ---------- Overall status ----------

overallStatus(Findings, red) :- member(finding(_, high, _), Findings).
overallStatus(Findings, orange) :- \+ member(finding(_, high, _), Findings), Findings \= [].
overallStatus([], green).
