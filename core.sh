# ======
# MACROS
# ======
# macro to print a line of equals
# (silly but works)
printSeparationLine() {
	str=${1:=}
	num=${2:-80}
	counter=1
	output=""
	while [ $counter -le $num ]; do
		output="${output}${str}"
		counter=$((counter + 1))
	done
	echo "${output}"
}

# macro to compute available space
# REF: https://unix.stackexchange.com/a/42049/60849
# REF: https://stackoverflow.com/a/450821/408734
getAvailableSpace() { echo $(df -a $1 | awk 'NR > 1 {avail+=$4} END {print avail}'); }

# macro to make Kb human readable (assume the input is Kb)
# REF: https://unix.stackexchange.com/a/44087/60849
formatByteCount() { echo $(numfmt --to=iec-i --suffix=B --padding=7 $1'000'); }

# macro to output saved space
printSavedSpace() {
	saved=${1}
	title=${2:-}

	echo ""
	printSeparationLine '*' 80
	if [ ! -z "${title}" ]; then
		echo "=> ${title}: Saved $(formatByteCount $saved)"
	else
		echo "=> Saved $(formatByteCount $saved)"
	fi
	printSeparationLine '*' 80
	echo ""
}

# macro to print output of dh with caption
printDH() {
	caption=${1:-}

	printSeparationLine '=' 80
	echo "${caption}"
	echo ""
	echo "$ dh -h /"
	echo ""
	df -h /
	echo "$ dh -a /"
	echo ""
	df -a /
	echo "$ dh -a"
	echo ""
	df -a
	printSeparationLine '=' 80
}

# ======
# SCRIPT
# ======
# Display initial disk space stats
AVAILABLE_INITIAL=$(getAvailableSpace)
AVAILABLE_ROOT_INITIAL=$(getAvailableSpace '/')

printDH "BEFORE CLEAN-UP:"
echo ""

# Option: Remove Android library

if [[ "${ANDROID}" == "true" ]]; then
	BEFORE=$(getAvailableSpace)
	sudo rm -rf /usr/local/lib/android
	AFTER=$(getAvailableSpace)
	SAVED=$((AFTER - BEFORE))
	printSavedSpace $SAVED "Android library"
fi

# Option: Remove .NET runtime

if [[ "${DOTNET}" == "true" ]]; then
	BEFORE=$(getAvailableSpace)

	# https://github.community/t/bigger-github-hosted-runners-disk-space/17267/11
	sudo rm -rf /usr/share/dotnet

	AFTER=$(getAvailableSpace)
	SAVED=$((AFTER - BEFORE))
	printSavedSpace $SAVED ".NET runtime"
fi

# Option: Remove Haskell runtime

if [[ "${INPUT_HASKELL}" == "true" ]]; then
	BEFORE=$(getAvailableSpace)

	sudo rm -rf /opt/ghc

	AFTER=$(getAvailableSpace)
	SAVED=$((AFTER - BEFORE))
	printSavedSpace $SAVED "Haskell runtime"
fi

# Option: Remove large packages
# REF: https://github.com/apache/flink/blob/master/tools/azure-pipelines/free_disk_space.sh

if [[ "${INPUT_LARGE-PACKAGES}" == "true" ]]; then
	BEFORE=$(getAvailableSpace)

	# Select alternative apt mirror since the original one is unstable
	sudo gem install apt-spy2
	sudo apt-spy2 fix --commit --launchpad --country=US
	sudo apt-get update

	sudo apt-get remove -y '^dotnet-.*'
	sudo apt-get remove -y '^llvm-.*'
	sudo apt-get remove -y 'php.*'
	sudo apt-get remove -y '^mongodb-.*'
	sudo apt-get remove -y '^mysql-.*'
	sudo apt-get remove -y azure-cli google-cloud-sdk google-chrome-stable firefox powershell mono-devel libgl1-mesa-dri
	sudo apt-get autoremove -y
	sudo apt-get clean

	AFTER=$(getAvailableSpace)
	SAVED=$((AFTER - BEFORE))
	printSavedSpace $SAVED "Large misc. packages"
fi

# Option: Remove Docker images
if [[ "${INPUT_DOCKER-IMAGES}" == 'true' ]]; then
	BEFORE=$(getAvailableSpace)
	sudo docker image prune --all --force
	AFTER=$(getAvailableSpace)
	SAVED=$((AFTER - BEFORE))
	printSavedSpace $SAVED "Docker images"
fi

# Option: Remove tool cache
# REF: https://github.com/actions/virtual-environments/issues/2875#issuecomment-1163392159

if [[ "${INPUT_TOOL-CACHE}" == "true" ]]; then
	BEFORE=$(getAvailableSpace)

	sudo rm -rf "$AGENT_TOOLSDIRECTORY"

	AFTER=$(getAvailableSpace)
	SAVED=$((AFTER - BEFORE))
	printSavedSpace $SAVED "Tool cache"
fi

# Option: Remove Swap storage

if [[ "${INPUT_SWAP-STORAGE}" == "true" ]]; then
	BEFORE=$(getAvailableSpace)

	sudo swapoff -a
	sudo rm -f /mnt/swapfile
	free -h

	AFTER=$(getAvailableSpace)
	SAVED=$((AFTER - BEFORE))
	printSavedSpace $SAVED "Swap storage"
fi

# Output saved space statistic
AVAILABLE_END=$(getAvailableSpace)
AVAILABLE_ROOT_END=$(getAvailableSpace '/')

echo ""
printDH "AFTER CLEAN-UP:"

echo ""
echo ""

echo "/dev/root:"
printSavedSpace $((AVAILABLE_ROOT_END - AVAILABLE_ROOT_INITIAL))
echo "overall:"
printSavedSpace $((AVAILABLE_END - AVAILABLE_INITIAL))
