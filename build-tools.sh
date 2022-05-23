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
NQBASEDIR="/tmp"
export PATH="$SCRIPTDIR"/tools:"$PATH"
NQ="$SCRIPTDIR"/tools/nq
TOOLS="
nq
saait
smu
entr
darkhttpd"

# nq
cd "$SCRIPTDIR"/nq || exit 1
make
cp -r nq fq nq.sh fq.sh ../tools/.
export NQDIR="$NQBASEDIR"/nq
"$NQ" -q make clean
cd - >/dev/null 2>&1 || exit 1

# saait
cd "$SCRIPTDIR"/saait || exit 1
export NQDIR="$NQBASEDIR"/saait
"$NQ" -q make
"$NQ" -q cp saait ../tools/.
"$NQ" -q make clean
cd - >/dev/null 2>&1 || exit 1

# smu
cd "$SCRIPTDIR"/smu || exit 1
export NQDIR="$NQBASEDIR"/smu
"$NQ" -q make
"$NQ" -q cp smu ../tools/.
"$NQ" -q make clean
cd - >/dev/null 2>&1 || exit 1

# entr
cd "$SCRIPTDIR"/entr || exit 1
export NQDIR="$NQBASEDIR"/entr
"$NQ" -q ./configure
"$NQ" -q make test
"$NQ" -q cp entr ../tools/.
"$NQ" -q make clean
cd - >/dev/null 2>&1 || exit 1

# darkhttpd
cd "$SCRIPTDIR"/darkhttpd || exit 1
export NQDIR="$NQBASEDIR"/darkhttpd
"$NQ" -q make
"$NQ" -q cp darkhttpd ../tools/.
"$NQ" -q make clean
cd - >/dev/null 2>&1 || exit 1

# wait
for TOOL in $TOOLS; do
	NQDIR="$NQBASEDIR"/"$TOOL" "$SCRIPTDIR"/nq/fq.sh
done

for TOOL in $TOOLS; do
	rm -rf "$NQBASEDIR"/"$TOOL"
done
