from mcp.server.fastmcp import Fast MCP
mcp=FastMCP ("Epay Assistant")
@mcp.tool()
def get_epay_status()->dict;
"Return the basic status of the Epay Appilcation"
retur{
    "Application:"Epay";
}