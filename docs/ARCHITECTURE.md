# Architecture

## Overview
Single Flutter monorepo for Windows, macOS, iOS, Android with shared domain + infrastructure layers.

## Layers
- `features`: UI screens and user flows.
- `domain`: operations, models, and service contracts.
- `infrastructure`: concrete local adapters (PDF engine, converters, storage, task execution).

## Conversion Engine
Plugin-style registry resolves converters by `JobType`.
- `HtmlToPdfConverter`
- `MarkdownToPdfConverter`
- `JsonToPdfConverter`
- `ImagesToPdfConverter`
- `PdfToImagesConverter`

## Task Execution Model
`TaskExecutorService` runs one task at a time from UI triggers.
The app enforces a lightweight single-operation flow with an in-app busy lock.

## Security and Offline
- No network dependency in conversion flow.
- Local workspace for temp/output files.
- Temp cleanup is centralized in workspace service.
