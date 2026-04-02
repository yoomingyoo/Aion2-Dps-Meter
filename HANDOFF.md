MGMeter / tk 포크 · 작업 인수인계 메모 (1페이지)
저장소·브랜치 (사용자 환경)
로컬 경로(포크 클론): d:\works\mg\git\MGMeter
GitHub 원격 이름: origin → git@github.com:yoomingyoo/Aion2-Dps-Meter.git
tk 공식: upstream → git@github.com:TK-open-public/Aion2-Dps-Meter.git
작업 브랜치: mg (git checkout -g 아님, 이미 생성됨: mg)
일상: mg에서 수정 → git add / git commit → 최초 git push -u origin mg, 이후 git push
tk 업데이트 반영(나중): git fetch upstream → main에 merge upstream/main(브랜치명 맞출 것) → mg에 merge main 등. 충돌 시 해당 파일만 수정.
이전 MGMeter 프로젝트 경로 (참고)
예전 작업 폴더: d:\works\mg\MGMeter (Cursor에서 열던 루트와 다를 수 있음)
지금은 tk 포크를 git\MGMeter 이름으로 클론해 같은 이름이지만 경로가 git 아래로 통일됨.
MGMeter에서 구현·결정했던 핵심 (tk와 별개로 했던 커스텀)
전투/집계

보스 메타에 의존하지 않음: 첫 데미지 이벤트로 전투 시작, 모든 targetId 데미지를 한 세션에 합산.
Refresh 시 이전 세션 저장·스토어 리셋 후 ARMED → 다음 데미지부터 새 세션.
유휴 시간으로 ENDING/ENDED (기존 warningAfterMillis / endAfterMillis).
파일: CombatSessionManager.kt 등.
닉네임 패킷

parseOwnActorPacket / parseOtherActorPacket에 extraHeaderLength 스킵 추가 (tk와 동일한 extra 플래그 대응).
액터 목록

몬스터가 플레이어를 치는 이벤트가 몹을 actor로 띄우지 않도록 DpsEngine에서 targetRuntimeStore.mobCode(actorId) 등으로 플레이어 이벤트만 집계.
메타 DB

tk의 skills.json / mobs.json(루트 배열 형식)을 src/main/resources/data/에 두고 MetadataRepository에서 로드.
샘플 JSON 제거; 없으면 빈 맵.
테스트

tk DB 기준으로 mobCode/skillId 기대값 수정 (예: 보스 코드 2980139, 스킬 30000071 등).
포터블 빌드

build.bat → build.ps1 (프로젝트 gradlew.bat, 기본 JDK `D:\tools\jdks\temurin-21`).
데이터는 별도 파일이 아니라 MGMeter-*.jar 안 data/skills.json, data/mobs.json 리소스로 포함.
tk 원본 동작 (참고·문서와 일치)
UI Refresh 버튼 제거 (Header 주석 처리).
핫키는 hardResetDps() → 백엔드 hardReset + 프론트 strongReset() (UI만 리셋하는 useMeter.reset()과 다름).
resetDps()가 resetDpsUI()를 호출하는데 프론트 TS에 해당 함수 정의는 검색되지 않음 (호출 경로에 따라는 이슈 가능).
포크 전략
**Git 유지 + upstream**이면 Beyond Compare로 두 폴더 전체 비교하는 방식 대신 **fetch + merge**로 대부분 처리 가능.
충돌 난 파일만 수동 병합/BC 사용.
새 채팅에서 할 일 예시
“워크스페이스: d:\works\mg\git\MGMeter, 브랜치 mg, upstream은 TK-open-public”이라고 밝히기.
위 구현 항목 중 이 포크(tk)에 남길 기능 / 버릴 기능 정하기.
tk 쪽은 이미 핫키 리셋·UI 구조가 바뀐 상태이므로, MGMeter에서 했던 변경을 tk에 이식할지, 포크에서만 유지할지 우선 결정.