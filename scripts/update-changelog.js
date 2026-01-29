#!/usr/bin/env node
/**
 * CHANGELOG.md 자동 업데이트 스크립트
 *
 * 사용법:
 *   node scripts/update-changelog.js --section Added --entry "- 새 기능 (#123)"
 *   node scripts/update-changelog.js --release --version 1.2.0
 *   node scripts/update-changelog.js --get-next-version
 */

import { readFileSync, writeFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const CHANGELOG_PATH = join(__dirname, '..', 'CHANGELOG.md');

const SECTIONS = ['Added', 'Changed', 'Deprecated', 'Removed', 'Fixed', 'Security'];

function parseArgs() {
  const args = process.argv.slice(2);
  const parsed = {
    section: null,
    entry: null,
    release: false,
    version: null,
    getNextVersion: false,
    prNumber: null,
    prTitle: null,
  };

  for (let i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--section':
        parsed.section = args[++i];
        break;
      case '--entry':
        parsed.entry = args[++i];
        break;
      case '--release':
        parsed.release = true;
        break;
      case '--version':
        parsed.version = args[++i];
        break;
      case '--get-next-version':
        parsed.getNextVersion = true;
        break;
      case '--pr-number':
        parsed.prNumber = args[++i];
        break;
      case '--pr-title':
        parsed.prTitle = args[++i];
        break;
    }
  }

  return parsed;
}

function readChangelog() {
  return readFileSync(CHANGELOG_PATH, 'utf-8');
}

function writeChangelog(content) {
  writeFileSync(CHANGELOG_PATH, content, 'utf-8');
}

/**
 * PR 제목에서 Conventional Commit 타입 추출
 * 예: "feat(auth): 로그인 기능" → { type: "feat", scope: "auth", description: "로그인 기능" }
 */
function parsePrTitle(title) {
  const match = title.match(/^(\w+)(?:\(([^)]+)\))?\s*:\s*(.+)$/);
  if (!match) {
    return { type: 'other', scope: null, description: title };
  }
  return {
    type: match[1],
    scope: match[2] || null,
    description: match[3],
  };
}

/**
 * Conventional Commit 타입을 CHANGELOG 섹션으로 매핑
 */
function typeToSection(type) {
  const mapping = {
    feat: 'Added',
    fix: 'Fixed',
    docs: 'Changed',
    style: 'Changed',
    refactor: 'Changed',
    perf: 'Changed',
    test: 'Changed',
    chore: 'Changed',
    build: 'Changed',
    ci: 'Changed',
    revert: 'Removed',
    security: 'Security',
  };
  return mapping[type] || 'Changed';
}

/**
 * [Unreleased] 섹션에 엔트리 추가
 */
function addEntry(content, section, entry) {
  if (!SECTIONS.includes(section)) {
    throw new Error(`Invalid section: ${section}. Must be one of: ${SECTIONS.join(', ')}`);
  }

  const lines = content.split('\n');
  let unreleasedIdx = lines.findIndex((line) => line.startsWith('## [Unreleased]'));

  if (unreleasedIdx === -1) {
    throw new Error('[Unreleased] section not found');
  }

  // 해당 섹션 찾기
  const sectionHeader = `### ${section}`;
  let sectionIdx = -1;
  let nextSectionIdx = lines.length;

  for (let i = unreleasedIdx + 1; i < lines.length; i++) {
    if (lines[i].startsWith('## [') && !lines[i].includes('[Unreleased]')) {
      nextSectionIdx = i;
      break;
    }
    if (lines[i] === sectionHeader) {
      sectionIdx = i;
    } else if (lines[i].startsWith('### ') && sectionIdx !== -1) {
      nextSectionIdx = i;
      break;
    }
  }

  // 섹션이 없으면 생성
  if (sectionIdx === -1) {
    // [Unreleased] 바로 다음에 섹션 추가
    const insertIdx = unreleasedIdx + 1;
    // 빈 줄이 있으면 그 다음에 추가
    const actualInsertIdx = lines[insertIdx] === '' ? insertIdx + 1 : insertIdx;

    lines.splice(actualInsertIdx, 0, '', sectionHeader, entry);
    return lines.join('\n');
  }

  // 기존 섹션에 엔트리 추가 (placeholder 대체 또는 추가)
  const placeholderPattern = /^\s*-\s*\(.*예정.*\)$/;

  // 섹션 내의 엔트리 위치 찾기
  let insertIdx = sectionIdx + 1;
  let hasPlaceholder = false;

  for (let i = sectionIdx + 1; i < nextSectionIdx; i++) {
    if (lines[i].startsWith('- ') || lines[i].match(/^\s*-/)) {
      if (placeholderPattern.test(lines[i])) {
        hasPlaceholder = true;
        insertIdx = i;
      } else {
        insertIdx = i + 1;
      }
    }
  }

  if (hasPlaceholder) {
    lines[insertIdx] = entry;
  } else {
    // 섹션 헤더 바로 다음에 추가
    lines.splice(sectionIdx + 1, 0, entry);
  }

  return lines.join('\n');
}

/**
 * [Unreleased] 섹션을 특정 버전으로 변환
 */
function release(content, version) {
  const today = new Date().toISOString().split('T')[0];
  const newVersionHeader = `## [${version}] - ${today}`;

  // [Unreleased] 를 새 버전으로 변경
  let result = content.replace(/## \[Unreleased\]/, `## [Unreleased]\n\n### Added\n- (예정된 기능 추가 시 여기에 기록)\n\n### Changed\n- (변경된 기능 있을 시 여기에 기록)\n\n### Fixed\n- (버그 수정 시 여기에 기록)\n\n---\n\n${newVersionHeader}`);

  return result;
}

/**
 * 다음 버전 번호 계산 (CHANGELOG에서 최신 버전 기반)
 */
function getNextVersion(content) {
  const versionMatch = content.match(/## \[(\d+)\.(\d+)\.(\d+)\]/);
  if (!versionMatch) {
    return '1.0.0';
  }

  const major = parseInt(versionMatch[1], 10);
  const minor = parseInt(versionMatch[2], 10);
  const patch = parseInt(versionMatch[3], 10);

  // 기본적으로 patch 버전 증가
  return `${major}.${minor}.${patch + 1}`;
}

/**
 * PR 정보를 기반으로 CHANGELOG 엔트리 생성
 */
function createEntryFromPr(prTitle, prNumber) {
  const { type, scope, description } = parsePrTitle(prTitle);
  const scopeStr = scope ? `**${scope}**: ` : '';
  return `- ${scopeStr}${description} (#${prNumber})`;
}

// 메인 실행
const args = parseArgs();

try {
  let content = readChangelog();

  if (args.getNextVersion) {
    console.log(getNextVersion(content));
    process.exit(0);
  }

  if (args.release) {
    const version = args.version || getNextVersion(content);
    content = release(content, version);
    writeChangelog(content);
    console.log(`Released version ${version}`);
    process.exit(0);
  }

  if (args.prTitle && args.prNumber) {
    const { type } = parsePrTitle(args.prTitle);
    const section = typeToSection(type);
    const entry = createEntryFromPr(args.prTitle, args.prNumber);
    content = addEntry(content, section, entry);
    writeChangelog(content);
    console.log(`Added entry to ${section}: ${entry}`);
    process.exit(0);
  }

  if (args.section && args.entry) {
    content = addEntry(content, args.section, args.entry);
    writeChangelog(content);
    console.log(`Added entry to ${args.section}`);
    process.exit(0);
  }

  console.error(`
사용법:
  node scripts/update-changelog.js --section Added --entry "- 새 기능 (#123)"
  node scripts/update-changelog.js --pr-title "feat(auth): 로그인" --pr-number 123
  node scripts/update-changelog.js --release --version 1.2.0
  node scripts/update-changelog.js --get-next-version
`);
  process.exit(1);
} catch (error) {
  console.error('Error:', error.message);
  process.exit(1);
}
