# RecipeSpark — AI Recipe Assistant

RecipeSpark is a Flutter mobile application that helps users decide what to cook based on the ingredients they have. It combines a structured recipe catalog, ingredient matching, smart search, AI-powered cooking assistance, favorites, and offline access to available content.

## App Screenshots
<img width="1214" height="1295" alt="RecipeSpark Cooking App Showcase" src="https://github.com/user-attachments/assets/64e225a6-0644-43aa-9b59-593a9b0354a3" />

> **Cook with what you have. Discover what you can make. Let AI guide you while you cook.**

## Table of Contents

- [Features](#features)
- [Screens](#screens)
- [Ingredient Matching](#ingredient-matching)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Running the App](#running-the-app)
- [Testing and Analysis](#testing-and-analysis)
- [AI Service Setup](#ai-service-setup)
- [Offline Support](#offline-support)
- [Design](#design)
- [Implementation Status](#implementation-status)
- [Future Enhancements](#future-enhancements)

## Features

- Discover recipes using ingredients selected by the user.
- Calculate ingredient match percentages from structured recipe data.
- Show missing required ingredients for each recipe.
- Search recipes by name and filter by categories.
- Browse detailed recipe information and ingredient quantities.
- Change serving sizes and recalculate ingredient quantities.
- Follow step-by-step cooking instructions.
- Save and remove favorite recipes.
- Ask recipe-related questions through the AI Cooking Assistant.
- Browse locally available recipes and saved content offline, depending on persistence setup.
- Explore the app as a guest without being forced to sign in.

## Screens

### Home

The Home screen provides access to recipe search, ingredient selection, meal categories, featured recipes, favorites, and the AI Cooking Assistant.

### Select Ingredients

Users can search for ingredients, browse ingredient categories, select multiple ingredients, and find recipes based on their selection. The selected ingredients should stay synchronized with the Home screen.

### Recipe Details

The Recipe Details screen shows the selected recipe’s image, description, rating when available, cooking and preparation times, difficulty, servings, ingredient match, ingredient quantities, and cooking instructions. Required, optional, and missing ingredients should be identified clearly.

### Cooking Instructions

Cooking Mode presents one instruction step at a time with progress, Previous Step and Next Step controls, helpful tips, and a completion state.

### Explore

Explore provides recipe search, category filters, and recipe cards based on the available recipe catalog.

### Saved Recipes

Users can view saved recipes, filter them by meal category, and remove favorites. An empty state should appear when no recipes have been saved.

### AI Cooking Assistant

The assistant provides suggested cooking questions and a conversation interface. If a real AI service is not configured, the app should clearly indicate that it is using local demonstration behavior.

### Profile

The Profile screen provides available profile information and settings. Statistics should be based on stored app data and must not be fabricated.

## Ingredient Matching

Recipe matching is calculated using required ingredients. Optional ingredients do not reduce the match score.

```text
Ingredient match (%) =
  matched required ingredients / total required ingredients × 100
```

Ingredient names should be normalized for case and surrounding whitespace before comparison. Results should show the match percentage, identify missing required ingredients, and be ranked by match relevance.

Recipes with no required ingredients and searches with no selected ingredients should be handled safely.

## Architecture

The app should keep user interface code separate from recipe data and business logic.

- **Models:** Represent recipes, ingredients, cooking steps, and related data.
- **Recipe catalog:** Provides structured recipe data from one centralized source.
- **Matching service:** Calculates ingredient matches and missing ingredients.
- **Shared state:** Keeps selected ingredients and favorites synchronized across screens.
- **Repository/data layer:** Provides a consistent interface for local and remote data.
- **Assistant service:** Provides an interface for future AI integration without exposing credentials in the Flutter app.
- **Local persistence:** Stores favorites and other supported data for offline use.

A suitable state-management approach should be selected for the project and used consistently.

## Project Structure

The exact structure may vary, but a maintainable layout can follow this pattern:

```text
lib/
├── main.dart
├── core/
│   ├── constants/
│   ├── theme/
│   └── widgets/
└── features/
    ├── assistant/
    ├── explore/
    ├── home/
    ├── ingredients/
    ├── navigation/
    ├── profile/
    ├── recipes/
    │   ├── data/
    │   ├── models/
    │   ├── screens/
    │   └── services/
    └── saved/
```

Tests can be organized under:

```text
test/
├── features/
│   ├── ingredients/
│   ├── recipes/
│   └── saved/
└── widget_test.dart
```

## Getting Started

### Requirements

- Flutter SDK installed and available on your `PATH`.
- Dart SDK compatible with the Flutter SDK.
- Android emulator, physical device, or another Flutter-supported target.

Check that Flutter is installed:

```bash
flutter --version
flutter doctor
```

### Install dependencies

From the project directory, run:

```bash
flutter pub get
```

## Running the App

Start an emulator or connect a device, then run:

```bash
flutter run
```

To list available devices:

```bash
flutter devices
```

To run on a specific device:

```bash
flutter run -d <device_id>
```

## Testing and Analysis

Format the Dart source code:

```bash
dart format lib
```

Run static analysis:

```bash
flutter analyze
```

Run the test suite:

```bash
flutter test
```

Tests should cover important business logic, including ingredient matching, missing ingredients, serving-size quantity calculations, and favorite state. Only report commands as successful after they have actually run and passed.

## AI Service Setup

The AI Cooking Assistant should use a clean service interface so a real AI provider can be connected later.

- Do not place API keys or other secrets in Flutter source code.
- Use a secure backend or protected service for real AI requests.
- Handle loading, empty, and error states.
- Do not claim that a real AI response succeeded when the service is unavailable.
- Clearly identify any local demonstration responses as demonstrations.

## Offline Support

Offline capabilities depend on the project’s data and persistence implementation. Supported locally stored content may include:

- Cached or downloaded recipes.
- Saved favorite recipes.
- Ingredient matching against locally available recipes.
- Recipe instructions and cooking mode.
- Other locally stored user data.

AI requests, cloud synchronization, and newly fetched content generally require a network connection.

## Design

RecipeSpark uses a warm, food-focused visual style:

- Cream background with orange accents.
- Rounded cards and pill-shaped controls.
- Clear typography and consistent spacing.
- High-quality food imagery where available.
- Responsive layouts for Android screen sizes.
- Reusable Flutter widgets for consistent controls and navigation.

Screens should be implemented with functional Flutter widgets, not as static screenshots or full-screen image backgrounds.

## Implementation Status

This README describes the intended product and setup workflow. It does not confirm that the project has been created or that any screen, feature, test, analysis command, or emulator run has been completed. Check the project source code and run the commands above to verify its actual status.

## Future Enhancements

Possible future features include:

- User-created and shared recipes.
- Shopping lists and missing-ingredient tracking.
- Meal planning and grocery planning.
- Voice-based ingredient entry and cooking assistance.
- Nutrition tracking and personalized recommendations.
