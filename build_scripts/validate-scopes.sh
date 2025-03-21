#!/bin/bash
# 빌드 구현 상 의존하는 환경 변수 목록
# $SCOPES => 빌드 대상 패키지 목록 => Ex) "example-server example-client"

echo "SCOPES=${SCOPES}"
if [ -z "$SCOPES" ]; then
    echo "SCOPES is empty"
    exit 1
fi