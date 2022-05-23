#!/usr/bin/env sh

# Copyright 2022 Ryan Horne
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

SCRIPTDIR=$(dirname "$0")
SCRIPTDIR=$(readlink -f "$SCRIPTDIR")
TOOLSBASE="$SCRIPTDIR"/tools
TOOLS="
darkhttpd
entr
nq
saait
smu"
NQ="$TOOLSBASE"/nq
ENTR="$TOOLSBASE"/entr
SAAIT="$TOOLSBASE"/saait
SMU="$TOOLSBASE"/smu

# ensure tools exist
for TOOL in $TOOLS; do
	if [ ! -f "$SCRIPTDIR"/tools/"$TOOL" ]; then
		>&2 echo "error: must run build.sh script first"
		exit 1
	fi
done
if ! which rsync >/dev/null 2>&1; then
	>&2 echo "error: must install rsync"
fi

# setup to use fq.sh and ENTR_INOTIFY_WORKAROUND if using WSL env
if $(uname -a | grep "microsoft.*WSL" >/dev/null 2>&1); then
	export FQ="$TOOLSBASE"/fq.sh  # probably same inotify thing
	export ENTR_INOTIFY_WORKAROUND="broken WSL"
else
	export FQ="$TOOLSBASE"/fq
fi

rebuild() {
	cd "$SCRIPTDIR" || exit 1

	rsync -a src/ output
	for MD in $(find output -name "*.md"); do
		HTML=$(basename "$MD" .md).html
		HTML=$(dirname "$MD")/"$HTML"
		"$SMU" -n < "$MD" > "$HTML"
		rm "$MD"
	done

	cd - >/dev/null 2>&1 || exit 1

	# rebuild each site
	for sitename in output/*; do
		mkdir -p "$sitename"/output
		find "$sitename"/pages -type f -name "*.cfg" -print0 |\
			sort -zr | \
			xargs -0 "$SAAIT" \
				-c "$sitename"/config.cfg \
				-o "$sitename"/output \
				-t "$sitename"/templates
		cp "$sitename"/*.css "$sitename"/output/
	done
}
if test x"$1" = x"rebuild"; then
	rebuild
	exit 0
fi

while :; do
find "$SCRIPTDIR"/src |  entr -d -n "$(readlink -f "$0")" rebuild
done

