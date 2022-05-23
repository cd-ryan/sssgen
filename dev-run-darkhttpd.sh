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
export PATH="$TOOLSBASE":"$PATH"
TOOLS="
darkhttpd
entr
nq
saait
smu"

# ensure tools exist
for TOOL in $TOOLS; do
	if [ ! -f "$SCRIPTDIR"/tools/"$TOOL" ]; then
		>&2 echo "error: must run build.sh script first"
		exit 1
	fi
done

"$TOOLSBASE"/darkhttpd "$SCRIPTDIR"/output --port "${HTTP_PORT:-8080}"

