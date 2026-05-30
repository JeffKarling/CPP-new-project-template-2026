#!/usr/bin/env python3
import os
import re

def main():
    # Setup paths relative to script location
    agent_dir = os.path.dirname(os.path.abspath(__file__))
    root_dir = os.path.dirname(agent_dir)
    scan_dirs = [
        os.path.join(root_dir, 'srcTargets'),
        os.path.join(root_dir, 'Documentation')
    ]
    roadmap_path = os.path.join(agent_dir, 'refactoring_roadmap.md')

    print("🚀 Running Agentic Comment Tag Parser...")
    print(f"📁 Scan Directories: {', '.join(scan_dirs)}")
    print(f"📄 Target Roadmap: {roadmap_path}")

    # Regex patterns for C++ style tags
    cpp_atr_pattern = re.compile(r'//\s*ATR:\s*(.*)')
    cpp_dis_pattern = re.compile(r'//\s*DIS:\s*(.*)')

    # Regex patterns for HTML/Markdown style tags
    md_atr_pattern = re.compile(r'<!--\s*ATR:\s*(.*)')
    md_dis_pattern = re.compile(r'<!--\s*DIS:\s*(.*)')

    atr_tasks = []
    dis_queries = []

    # Recursively scan target directories
    for scan_dir in scan_dirs:
        if not os.path.exists(scan_dir):
            continue
        for root, _, files in os.walk(scan_dir):
            for file in files:
                if file.endswith(('.cpp', '.h', '.hpp', '.md')):
                    file_path = os.path.join(root, file)
                    rel_path = os.path.relpath(file_path, root_dir)
                    abs_path = os.path.abspath(file_path)

                    is_md = file.endswith('.md')
                    atr_pattern = md_atr_pattern if is_md else cpp_atr_pattern
                    dis_pattern = md_dis_pattern if is_md else cpp_dis_pattern

                    try:
                        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                            for line_num, line in enumerate(f, 1):
                                atr_match = atr_pattern.search(line)
                                if atr_match:
                                    desc = atr_match.group(1).strip()
                                    if is_md and desc.endswith('-->'):
                                        desc = desc[:-3].strip()
                                    if desc:
                                        atr_tasks.append({
                                            'desc': desc,
                                            'rel_path': rel_path,
                                            'abs_path': abs_path,
                                            'basename': file,
                                            'line': line_num
                                        })

                                dis_match = dis_pattern.search(line)
                                if dis_match:
                                    desc = dis_match.group(1).strip()
                                    if is_md and desc.endswith('-->'):
                                        desc = desc[:-3].strip()
                                    if desc:
                                        dis_queries.append({
                                            'desc': desc,
                                            'rel_path': rel_path,
                                            'abs_path': abs_path,
                                            'basename': file,
                                            'line': line_num
                                        })
                    except Exception as e:
                        print(f"⚠️ Error reading {file_path}: {e}")

    # Format the collected items
    atr_md = []
    if atr_tasks:
        for task in atr_tasks:
            link = f"file://{task['abs_path']}#L{task['line']}"
            atr_md.append(f"- [ ] {task['desc']} ([{task['basename']}:{task['line']}]({link}))")
    else:
        atr_md.append("*No inline tasks currently found.*")

    dis_md = []
    if dis_queries:
        for query in dis_queries:
            link = f"file://{query['abs_path']}#L{query['line']}"
            dis_md.append(f"- [ ] {query['desc']} ([{query['basename']}:{query['line']}]({link}))")
    else:
        dis_md.append("*No inline design discussions currently found.*")

    # Read and update refactoring_roadmap.md
    if not os.path.exists(roadmap_path):
        print(f"❌ Error: Roadmap file does not exist at {roadmap_path}")
        return

    with open(roadmap_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Replace content between START_AUTO_ATR and END_AUTO_ATR
    atr_block_pattern = re.compile(
        r'(<!--\s*START_AUTO_ATR\s*-->).*?(<!--\s*END_AUTO_ATR\s*-->)', 
        re.DOTALL
    )
    new_atr_content = f"\\1\n" + "\n".join(atr_md) + "\n\\2"
    content = atr_block_pattern.sub(new_atr_content, content)

    # Replace content between START_AUTO_DIS and END_AUTO_DIS
    dis_block_pattern = re.compile(
        r'(<!--\s*START_AUTO_DIS\s*-->).*?(<!--\s*END_AUTO_DIS\s*-->)', 
        re.DOTALL
    )
    new_dis_content = f"\\1\n" + "\n".join(dis_md) + "\n\\2"
    content = dis_block_pattern.sub(new_dis_content, content)

    with open(roadmap_path, 'w', encoding='utf-8') as f:
        f.write(content)

    print("\n📊 Scan Summary:")
    print(f"  ✨ Found {len(atr_tasks)} inline tasks (//ATR)")
    print(f"  ✨ Found {len(dis_queries)} inline discussions (//DIS)")
    print("✅ Roadmap updated successfully.")

if __name__ == '__main__':
    main()
