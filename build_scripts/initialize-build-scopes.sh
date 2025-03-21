#!/bin/bash
# 빌드 구현 상 의존하는 환경 변수 목록
# $PR_NAME => PR 이름 => Ex) "[example-server,example-client] 기능 추가"

function in_array {
	local INPUT_VALUE=${1}
	declare ARRAY=${2}
	for VALUE in ${ARRAY[@]}; do
		if [[ "${VALUE}" == "${INPUT_VALUE}" ]]; then
			return 1
		fi
	done
	return 0
}

function validate_package {
	declare PACKAGE_ARRAY=${1}
    declare ENTIRE_PACKAGE_ARRAY=${2}
	for PACKAGE in ${PACKAGE_ARRAY[@]}; do
		if in_array "${PACKAGE}" "${ENTIRE_PACKAGE_ARRAY}"; then
			echo "Error : Wrong PACKAGE!, '${PACKAGE}'"
			exit 1
		fi
	done
	return 0
}

function parse_package_names_from_pr_name {
	local PR_NAME=${1}
	local RESULT=""
	IFS=',' read -ra RESULT <<< "$(echo "${PR_NAME}" | sed -n 's/.*\[\([^]]*\)\].*/\1/p')"
	echo "${RESULT[@]}"
	return
}

function find_all_packages {
	local RESULT=""
	RESULT=$(pnpm recursive exec -- bash -c 'echo $(jq -r ".name" package.json)' -- | tr "\n" ' ')
	echo "${RESULT[@]}"
	return
}

function validate_pr_name_format {
    local PR_NAME=${1}
    
    if [[ -z "${PR_NAME}" ]]; then
        echo "Error: PR_NAME이 비어 있습니다."
        exit 1
    fi

    if ! [[ "${PR_NAME}" =~ ^\[.+\]\ .+$ ]]; then
        echo "Error: PR_NAME 형식이 올바르지 않습니다."
        echo "올바른 형식: '[패키지1] 제목' 또는 '[패키지1,패키지2,...] 제목'"
        echo "예시: '[example-server] 기능 추가' 또는 '[example-server,example-client] 버그 수정'"
        exit 1
    fi
    
    local BRACKET_CONTENT=$(echo "${PR_NAME}" | sed -n 's/^\[\([^]]*\)\].*/\1/p')
    if [[ -z "${BRACKET_CONTENT}" ]]; then
        echo "Error: 대괄호 안에 패키지 이름이 없습니다."
        exit 1
    fi
    
    return 0
}

function init_build_option {
	BASE_BRANCH=${1}

	ENTIRE_PACKAGE_ARRAY=$(find_all_packages)

	PR_NAME=$(echo "$PR_NAME" | xargs)
	validate_pr_name_format "${PR_NAME}"

	PACKAGE_ARRAY=$(parse_package_names_from_pr_name "${PR_NAME}")
	validate_package "${PACKAGE_ARRAY}" "${ENTIRE_PACKAGE_ARRAY}"

	echo "SCOPES=$SCOPES" >>$GITHUB_ENV
	echo "SCOPES=${PACKAGE_ARRAY}"
}

init_build_option "dev"
