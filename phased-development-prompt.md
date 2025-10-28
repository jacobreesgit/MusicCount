# Phased Development Plan Prompt

## Prompt for AI Assistant

```
You are an expert iOS developer with deep knowledge of Swift, SwiftUI, and Apple's MediaPlayer framework. You specialize in creating well-structured, phased development plans for iOS applications.

## Project Context
Create a phased development plan for an iOS app with the following requirements:
- Access the user's local music library using MPMediaLibrary (NO external APIs like MusicKit)
- Display a list of songs with their play counts
- Allow users to select and compare play counts between two songs
- Must use native iOS frameworks only (MediaPlayer framework)
- Target iOS 13+ with Swift and SwiftUI

## Critical Unknown
There is uncertainty about what content MPMediaLibrary can actually access on modern iOS devices (local vs Apple Music streaming content). Phase 1 MUST verify this before proceeding with full development.

## Your Task
Create a comprehensive phased development plan document with the following structure:

### Phase 1: Technical Verification & Proof of Concept (PRIORITY)
- Build a minimal test app to verify MPMediaLibrary access
- Test what types of music are accessible (iTunes purchases, synced files, Apple Music downloads, streaming content)
- Document play count availability and accuracy
- Identify technical limitations and blockers
- Provide clear go/no-go recommendation for proceeding to Phase 2
- Estimated timeline: 3-5 days
- **Deliverable:** Technical verification report with screenshots/data showing what's accessible

### Phase 2-4: Plan the remaining phases ONLY IF Phase 1 verification is successful
Structure each phase with:
- Specific technical objectives
- Required iOS APIs and frameworks
- Implementation details
- Acceptance criteria
- Estimated timeline
- Deliverables
- Dependencies on previous phases

Include these subsequent phases:
- Phase 2: Core library access & data layer
- Phase 3: UI implementation (list view, search, selection)
- Phase 4: Comparison feature & polish

## Requirements for Your Output
1. Be technically specific (mention exact APIs, classes, methods like MPMediaQuery, MPMediaItem.playCount)
2. Include code-level details where relevant (not full code, just key technical approaches)
3. Address permission handling (NSAppleMusicUsageDescription, authorization flow)
4. Identify technical risks in each phase
5. Provide realistic time estimates
6. Make Phase 1 extremely detailed since it's the critical validation step
7. Keep Phases 2-4 moderate detail since they depend on Phase 1 success

Format the output as a professional development plan document with clear sections, bullet points, and technical specifications.
```

## Reasoning for Prompt Structure

**Context Setting:** Establishes expertise in iOS development to prime for technical depth and accuracy in the response.

**Project Context Section:** Provides all the constraints and requirements upfront so the generated plan stays within bounds (no MusicKit, native frameworks only).

**Critical Unknown Emphasis:** Highlights the key uncertainty - whether MPMediaLibrary actually works for modern users - making it clear Phase 1 is about verification, not just starting development.

**Phase 1 Detail:** Made Phase 1 extremely specific because this is the actual goal - we need to TEST the library access before committing to full development. Includes concrete deliverables (verification report, screenshots) to ensure actionable output.

**Conditional Phases 2-4:** Structured as dependent on Phase 1 success, acknowledging the project may not be feasible and we shouldn't over-plan if the technology doesn't work.

**Technical Specificity Requirements:** Explicitly asks for API names, class references, and code-level details to ensure the output is actionable for actual implementation, not just high-level planning.

**Professional Format:** Ensures the output will be a usable project document with timelines, deliverables, and acceptance criteria.

This prompt should generate a practical, phased plan that starts with verification (addressing concerns about whether MPMediaLibrary can actually access content on iPhone) before committing to full development.
