# Cursor Rules Overview - Veepai Camera AI SDK

## Purpose
This rule set guides AI-assisted development for a custom Flutter camera application using the Veepai SDK. Rules enforce Clean Architecture, SOLID principles, and performance optimization.

## Rule Structure
Each rule file contains:
- **Scope**: Which files/patterns the rule applies to
- **Description**: What the rule enforces
- **Directives**: Specific, actionable guidelines
- **Examples**: Code snippets demonstrating good practices

## Rule Categories

### Core Rules (01-03)
- **01-senior-persona.md**: AI assistant role and behavior
- **02-clean-architecture.md**: Layered architecture enforcement
- **03-code-quality.md**: Code standards and KISS principles

### Implementation Rules (04-06)
- **04-solid-principles.md**: S.O.L.I.D application in practice
- **05-performance.md**: RxDart, Isolates, multi-threading
- **06-testing.md**: Unit, widget, integration testing

### Platform Rules (07-09)
- **07-flutter-dart.md**: Flutter/Dart best practices
- **08-kotlin-android.md**: Kotlin native layer
- **09-swift-ios.md**: Swift native layer

### SDK & Domain Rules (10-12)
- **10-veepai-sdk.md**: SDK integration patterns
- **11-ai-ml.md**: AI/ML feature implementation
- **12-error-handling.md**: Error handling strategies

## How to Use
1. Rules are evaluated in order (00 → 12)
2. More specific rules override general ones
3. All rules work together - not mutually exclusive
4. Update rules as project evolves

## Version
- Created: October 16, 2025
- Flutter: 3.x
- Veepai SDK: 2.x-4.x

