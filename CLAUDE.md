# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Model Context Protocol (MCP) server that provides tools for interacting with PocketBase databases. It enables database operations, schema management, and data manipulation through the MCP interface.

**Key characteristics:**
- Built with TypeScript and the `@modelcontextprotocol/sdk`
- Uses the official PocketBase JavaScript SDK v0.26.1
- Single-file architecture in `src/index.ts`
- Communicates via stdio transport for MCP integration

## Build and Development Commands

```bash
# Build the project (compiles TypeScript to build/ directory and sets executable permissions)
npm run build

# Build and start the server
npm run start

# Development mode with watch
npm run dev
```

## Architecture

### Core Structure

The entire MCP server is implemented in a single class `PocketBaseServer` in `src/index.ts`:

1. **Initialization** (`constructor`):
   - Creates an MCP Server instance with name "pocketbase-server" v0.1.0
   - Initializes PocketBase client with `POCKETBASE_URL` from environment
   - Sets up tool handlers and error handling

2. **Tool Registration** (`setupToolHandlers`):
   - Registers all available MCP tools via `ListToolsRequestSchema` handler
   - Routes tool calls via `CallToolRequestSchema` handler to appropriate private methods

3. **Tool Implementation**:
   - Each MCP tool maps to a private method (e.g., `createCollection`, `createRecord`)
   - Admin operations automatically authenticate with `_superusers` collection using environment credentials
   - All responses return JSON-formatted content in MCP format

### Authentication Pattern

Admin-only operations (collections, backups) follow this pattern:
```typescript
await this.pb.collection("_superusers").authWithPassword(
  process.env.POCKETBASE_ADMIN_EMAIL ?? '',
  process.env.POCKETBASE_ADMIN_PASSWORD ?? ''
);
```

Regular user authentication uses the specified collection (defaults to "users").

### Error Handling

The codebase includes custom error utilities at the bottom of `src/index.ts`:

- `flattenErrors(errors)`: Recursively extracts error messages from nested PocketBase error objects
- `pocketbaseErrorMessage(errors)`: Formats flattened errors into readable messages
- All tool methods wrap errors in `McpError` with appropriate error codes

## Environment Configuration

Required:
- `POCKETBASE_URL`: URL of your PocketBase instance (e.g., "http://127.0.0.1:8090")

Optional:
- `POCKETBASE_ADMIN_EMAIL`: Admin email for collection/backup operations
- `POCKETBASE_ADMIN_PASSWORD`: Admin password
- `POCKETBASE_DATA_DIR`: Custom data directory path

Copy `.env.example` to `.env` and configure as needed (though environment variables are typically set by the MCP client config).

## Available MCP Tools

### Collection Management (Admin Required)
- `create_collection`: Create collection with schema (auto-adds "created" and "updated" autodate fields)
- `update_collection`: Update existing collection schema
- `get_collection`: Get collection details
- `list_collections`: List all collections with optional filter/sort
- `delete_collection`: Delete a collection

### Record Operations
- `create_record`: Create a record in a collection
- `list_records`: List records with filter, sort, pagination
- `update_record`: Update an existing record
- `delete_record`: Delete a record

### User Management
- `authenticate_user`: Authenticate with email/password (supports admin via `isAdmin: true`)
- `create_user`: Create new user account
- Additional auth tools defined but not fully implemented in handlers (OAuth2, OTP, verification, password reset, email change, impersonation)

### Database Operations (Admin Required)
- `backup_database`: Create database backup
- `import_data`: Import records (defined but not implemented in handler)

## Important Notes

### Collection Schema Fields

When creating collections, **never manually add "created" or "updated" fields** - these are automatically added as autodate fields by the `createCollection` method (see lines 718-739).

### Field Types

Supported field types in collection schemas:
- `bool`, `date`, `number`, `text`, `email`, `url`, `editor`
- `autodate` (for timestamps)
- `select` (requires `values` array)
- `file`, `relation` (requires `collectionId`)
- `json`

### Admin vs User Collections

- Admin operations use the `_superusers` collection
- User operations default to the `users` collection (can be overridden with `collection` parameter)
- Auth collections support password authentication configuration via `passwordAuth` option

## TypeScript Configuration

- Target: ES2020 modules
- Output directory: `build/`
- Strict mode enabled
- Declaration files generated
