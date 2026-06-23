#!/usr/bin/env python3
"""
CIM Skills MCP Server — exposes CIM API skill library to other AI agents.

Tools:
  - list_skills: List all available CIM skills with metadata
  - get_skill: Load a complete skill file by name
  - list_agents: List CIM analysis and integration agents
  - get_benchmark: Get benchmark/documentation for a skill
  - run_skill: Prepare skill + context for LLM execution

Uses FastMCP from the `mcp` package (v1.26.0+).

Start: python mcp/cim_skills_mcp_server.py
Register in .claude.json:
  "mcpServers": {
    "cim-skills": {
      "command": "python",
      "args": ["<absolute-path>/cim-skills/mcp/cim_skills_mcp_server.py"]
    }
  }
"""
import json
import sys
from pathlib import Path

# Resolve paths
SCRIPT_DIR = Path(__file__).resolve().parent
ROOT = SCRIPT_DIR.parent  # cim-skills/mcp/ -> cim-skills/
SKILLS_DIR = SCRIPT_DIR.parent / "skills"
AGENTS_DIR = ROOT / "agents"

# Skill catalog — maps slug to directory name
SKILL_CATALOG = {
    "initialization": {
        "dir": "initialization",
        "description": "CIM API SDK 安装初始化与通用行为。包含SDK安装、插件初始化、版本查询与实体对象通用操作",
        "tags": ["cimapi", "init", "plugin", "version"],
        "version": "1.4.0",
        "frameworks": 3,
        "lines": 200,
    },
    "box": {
        "dir": "box",
        "description": "空间管理工具（App.HimRoomBox）。通过geojson加载room色块、控制颜色、高亮、显隐、聚焦与查询",
        "tags": ["cimapi", "hospital", "room-box", "scene", "interaction"],
        "version": "1.4.0",
        "frameworks": 1,
        "lines": 150,
    },
    "device": {
        "dir": "device",
        "description": "附属设备管理工具（App.HimAttachedDevice）。创建模板、附属设备管理、删除与获取列表",
        "tags": ["cimapi", "hospital", "attached-device", "management"],
        "version": "1.4.0",
        "frameworks": 1,
        "lines": 200,
    },
    "elevator": {
        "dir": "elevator",
        "description": "电梯管理模块。创建电梯对象、更新样式、显示隐藏、升降控制、高亮与交互事件",
        "tags": ["cimapi", "hospital", "elevator", "scene", "interaction"],
        "version": "1.4.0",
        "frameworks": 1,
        "lines": 180,
    },
    "keycommon": {
        "dir": "keycommon",
        "description": "设置高德地图key工具（App.cim.InternetMapCommon）。动态配置地图访问密钥",
        "tags": ["cimapi", "internet-map", "key", "config"],
        "version": "1.4.0",
        "frameworks": 1,
        "lines": 80,
    },
    "bycircle": {
        "dir": "bycircle",
        "description": "POI圆形搜索工具（App.cim.InternetMapPoiByCircle）。根据圆心和半径搜索POI、分类筛选、自定义样式",
        "tags": ["cimapi", "internet-map", "poi", "circle", "search"],
        "version": "1.4.0",
        "frameworks": 1,
        "lines": 150,
    },
    "bypolygon": {
        "dir": "bypolygon",
        "description": "POI多边形搜索工具（App.cim.InternetMapPoiByPolygon）。根据多边形范围搜索POI、分类筛选、自定义样式",
        "tags": ["cimapi", "internet-map", "poi", "polygon", "search"],
        "version": "1.4.0",
        "frameworks": 1,
        "lines": 150,
    },
    "byscreen": {
        "dir": "byscreen",
        "description": "POI屏幕搜索工具（App.cim.InternetMapPoiByScreen）。根据屏幕视野范围搜索POI、分类筛选、自定义样式",
        "tags": ["cimapi", "internet-map", "poi", "screen", "search"],
        "version": "1.4.0",
        "frameworks": 1,
        "lines": 150,
    },
    "bytext": {
        "dir": "bytext",
        "description": "POI文字搜索工具（App.cim.InternetMapPoi）。根据文字关键词搜索POI、分类筛选、自定义样式挂载",
        "tags": ["cimapi", "internet-map", "poi", "search"],
        "version": "1.4.0",
        "frameworks": 1,
        "lines": 150,
    },
    "poi-get": {
        "dir": "poi-get",
        "description": "获取已搜索的POI对象（App.cim.InternetMapPoiGet）。按分类筛选、查询信息、控制显隐、更新样式、删除或聚焦",
        "tags": ["cimapi", "internet-map", "poi", "get"],
        "version": "1.4.0",
        "frameworks": 1,
        "lines": 150,
    },
    "poi-reset": {
        "dir": "poi-reset",
        "description": "清除已搜索的POI（App.cim.InternetMapPoiReset）。按分类清除或清除全部POI对象",
        "tags": ["cimapi", "internet-map", "poi", "reset"],
        "version": "1.4.0",
        "frameworks": 1,
        "lines": 80,
    },
    "search-path": {
        "dir": "search-path",
        "description": "导航路径工具（App.InternetMapPath）。两点间导航、自定义路径样式、删除已有路径",
        "tags": ["cimapi", "internet-map", "navigation", "path"],
        "version": "1.4.0",
        "frameworks": 1,
        "lines": 150,
    },
    "select-path": {
        "dir": "select-path",
        "description": "选择导航路径（SelectNaviPath）。从高德地图返回的多条导航路线中选择一条",
        "tags": ["cimapi", "internet-map", "navigation"],
        "version": "1.4.0",
        "frameworks": 1,
        "lines": 100,
    },
    "get-path": {
        "dir": "get-path",
        "description": "获取导航路径对象（App.InternetMapPath）。对已添加的路径进行显隐、更新、删除与聚焦操作",
        "tags": ["cimapi", "internet-map", "navigation", "path"],
        "version": "1.4.0",
        "frameworks": 1,
        "lines": 150,
    },
    "lifecircle": {
        "dir": "lifecircle",
        "description": "N分钟生活圈能力（App.cim.InternetMapLifeCircle）。按时间与出行方式计算可达范围与可视化",
        "tags": ["cimapi", "internet-map", "life-circle", "range"],
        "version": "1.4.0",
        "frameworks": 1,
        "lines": 150,
    },
    "contour": {
        "dir": "contour",
        "description": "等高线分析工具（App.ContourAnalysis）。地形高程分析、等高线与等高面样式配置",
        "tags": ["cimapi", "analysis", "contour", "visualization"],
        "version": "1.4.0",
        "frameworks": 1,
        "lines": 150,
    },
    "dig-terrain": {
        "dir": "dig-terrain",
        "description": "填挖方分析工具（App.DigTerrainAnalysis）。土方工程分析、挖方深度配置与结果展示",
        "tags": ["cimapi", "analysis", "dig-terrain", "earthwork"],
        "version": "1.4.0",
        "frameworks": 1,
        "lines": 150,
    },
    "height-limit": {
        "dir": "height-limit",
        "description": "限高分析工具（App.HeightLimitAnalysis）。限高检测、超限区域标记、限高阈值配置",
        "tags": ["cimapi", "analysis", "height-limit", "visualization"],
        "version": "1.4.0",
        "frameworks": 1,
        "lines": 150,
    },
    "intervisible": {
        "dir": "intervisible",
        "description": "通视分析工具（App.IntervisibleAnalysis）。观察点与目标点可视性检测、视线遮挡分析",
        "tags": ["cimapi", "analysis", "intervisible", "line-of-sight"],
        "version": "1.4.0",
        "frameworks": 1,
        "lines": 150,
    },
    "openness": {
        "dir": "openness",
        "description": "开敞度分析工具（App.OpennessAnalysis）。开敞程度评估、扇形区域可视分析、样式配置",
        "tags": ["cimapi", "analysis", "openness", "visualization"],
        "version": "1.4.0",
        "frameworks": 1,
        "lines": 150,
    },
    "skyline": {
        "dir": "skyline",
        "description": "天际线分析工具（App.SkyLineAnalysis）。建筑轮廓天际线分析、线条样式与截图输出",
        "tags": ["cimapi", "analysis", "skyline", "visualization"],
        "version": "1.4.0",
        "frameworks": 1,
        "lines": 150,
    },
    "sunlight": {
        "dir": "sunlight",
        "description": "日照分析工具（App.SunLightAnalysis）。光照覆盖评估、建筑方案比选、采光评估",
        "tags": ["cimapi", "analysis", "sunlight", "simulation"],
        "version": "1.4.0",
        "frameworks": 1,
        "lines": 200,
    },
}

# Agent catalog
AGENT_CATALOG = [
    {"name": "API Explorer", "capability": "discovery", "description": "发现CIM API能力并建议最佳实践"},
    {"name": "Scene Builder", "capability": "construction", "description": "构建和管理3D场景对象"},
    {"name": "Analysis Engine", "capability": "computation", "description": "执行空间分析和计算"},
    {"name": "POI Manager", "capability": "data_management", "description": "管理兴趣点数据和搜索"},
    {"name": "Navigation Manager", "capability": "routing", "description": "处理导航和路径规划"},
    {"name": "Style Configurator", "capability": "visualization", "description": "配置视觉样式和渲染效果"},
    {"name": "Event Handler", "capability": "interaction", "description": "处理场景交互事件"},
    {"name": "Performance Monitor", "capability": "optimization", "description": "监控和优化性能"},
]


def list_skills() -> str:
    """List all available CIM skills with metadata.

    Returns JSON array of skill objects with name, description, tags, version.
    """
    skills = []
    for slug, info in SKILL_CATALOG.items():
        if info.get("private"):
            continue  # Don't expose private skills
        skills.append({
            "name": slug,
            "description": info["description"],
            "tags": info["tags"],
            "version": info["version"],
            "frameworks": info["frameworks"],
            "lines": info["lines"],
        })
    return json.dumps(skills, indent=2)


def get_skill(skill_name: str) -> str:
    """Load a complete skill file by name.

    Returns the full SKILL.md content as a string.
    If the skill is not found, returns an error message.
    """
    info = SKILL_CATALOG.get(skill_name)
    if not info:
        available = ", ".join(k for k, v in SKILL_CATALOG.items() if not v.get("private"))
        return f"Error: Skill '{skill_name}' not found. Available: {available}"

    if info.get("private"):
        return f"Error: Skill '{skill_name}' is private and cannot be accessed via MCP."

    skill_path = SKILLS_DIR / info["dir"] / "SKILL.md"
    if not skill_path.exists():
        return f"Error: Skill file not found at {skill_path}"

    return skill_path.read_text(encoding="utf-8")


def list_agents() -> str:
    """List Agent Prime's agent capabilities.

    Returns JSON array of agent objects with name, capability, description.
    """
    return json.dumps(AGENT_CATALOG, indent=2)


def get_benchmark(skill_name: str) -> str:
    """Get benchmark results for a skill.

    Returns benchmark score and details if available.
    """
    if skill_name == "initialization":
        return json.dumps({
            "skill": skill_name,
            "version": "1.4.0",
            "status": "production",
            "documentation": "SDK安装与初始化完整文档",
            "date": "2026-04-23",
        }, indent=2)
    return json.dumps({
        "skill": skill_name,
        "version": "1.4.0",
        "status": "production",
        "note": "CIM Skills已全部用于生产环境。所有skill均基于官方CIM API接口文档编写。",
    }, indent=2)


def run_skill(skill_name: str, context: str) -> str:
    """Prepare a skill + context for LLM execution.

    Returns the skill content followed by the context, formatted for
    an LLM to process according to the skill's methodology.
    """
    skill_content = get_skill(skill_name)
    if skill_content.startswith("Error:"):
        return skill_content

    return f"""# CIM Skill: {skill_name}

{skill_content}

---

# Context for Implementation

{context}

---

# Instructions

按照上述CIM Skill文档的内容进行实现。应用所有相关的API方法和最佳实践。生成输出应符合该skill的要求与API规范。实现前进行完整性检查。
"""


def start_server():
    """Start the MCP server using FastMCP."""
    try:
        from mcp.server.fastmcp import FastMCP
    except ImportError:
        print("Error: mcp package not installed. Run: pip install mcp", file=sys.stderr)
        sys.exit(1)

    mcp = FastMCP("CIM Skills Arsenal")

    @mcp.tool()
    def tool_list_skills() -> str:
        """List all available CIM skills with metadata (name, description, tags, version, framework count)."""
        return list_skills()

    @mcp.tool()
    def tool_get_skill(skill_name: str) -> str:
        """Load a complete CIM skill file by name. Returns the full SKILL.md content."""
        return get_skill(skill_name)

    @mcp.tool()
    def tool_list_agents() -> str:
        """List CIM API 8 agent capabilities (name, role, description)."""
        return list_agents()

    @mcp.tool()
    def tool_get_benchmark(skill_name: str) -> str:
        """Get benchmark score and evaluation details for a CIM skill."""
        return get_benchmark(skill_name)

    @mcp.tool()
    def tool_run_skill(skill_name: str, context: str) -> str:
        """Prepare a CIM skill + context for LLM execution. Returns skill content + context + instructions."""
        return run_skill(skill_name, context)

    @mcp.resource("skills://health", name="health", description="Health check for CIM Skills MCP server")
    def health_check() -> str:
        """Health check — returns server status, skill count, and agent count."""
        public_skills = [k for k, v in SKILL_CATALOG.items() if not v.get("private")]
        skill_files_found = 0
        for slug in public_skills:
            info = SKILL_CATALOG[slug]
            skill_path = SKILLS_DIR / info["dir"] / "SKILL.md"
            if skill_path.exists():
                skill_files_found += 1

        return json.dumps({
            "status": "ok",
            "server": "CIM Skills Arsenal",
            "skills_registered": len(public_skills),
            "skills_on_disk": skill_files_found,
            "agents_registered": len(AGENT_CATALOG),
            "skills_dir": str(SKILLS_DIR),
        }, indent=2)

    mcp.run()


if __name__ == "__main__":
    if "--test" in sys.argv:
        # Quick self-test without starting the server
        print("Testing MCP server functions...")
        skills = json.loads(list_skills())
        print(f"  list_skills: {len(skills)} skills")
        assert len(skills) >= 22  # At least 22 public CIM skills

        skill_content = get_skill("initialization")
        assert not skill_content.startswith("Error"), f"Unexpected error: {skill_content[:100]}"
        print(f"  get_skill: {len(skill_content)} chars")

        agents = json.loads(list_agents())
        print(f"  list_agents: {len(agents)} agents")
        assert len(agents) >= 8

        benchmark = json.loads(get_benchmark("initialization"))
        print(f"  get_benchmark: {benchmark['version']}")
        assert benchmark["version"] == "1.4.0"

        print("\nAll MCP server self-tests passed.")
    else:
        start_server()
