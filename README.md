# NewRoomModel

A 3D model of a room, built in Blender 5.2 and driven by Claude Code through the [blender-mcp](https://github.com/ahujasid/blender-mcp) server.

## Setup

1. Register the MCP server with Claude Code:
   ```
   claude mcp add --scope user blender -- uvx mcp-for-blender
   ```
2. Install the Blender add-on:
   ```
   uvx mcp-for-blender install-addon
   ```
3. In Blender, enable **Interface: MCP for Blender**, press `N` in the 3D viewport, open the **MCP for Blender** tab and click **Start MCP Server**.

The community server runs LLM-generated Python inside Blender with no guards, so save the `.blend` file often.
