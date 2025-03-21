#!/bin/bash
# 빌드 구현 상 의존하는 환경 변수 목록
# $SCOPES => 빌드 대상 패키지 목록 => Ex) "example-server example-client"

MULTIPLE_COMMAND="pnpm"
INCLUDE_OPTION="--filter"
for PACKAGE in ${SCOPES[*]};do
    MULTIPLE_COMMAND="${MULTIPLE_COMMAND} ${INCLUDE_OPTION}=${PACKAGE}"
done

echo "MULTIPLE_COMMAND=${MULTIPLE_COMMAND}"
echo "MULTIPLE_COMMAND=${MULTIPLE_COMMAND}" >> ${GITHUB_ENV}