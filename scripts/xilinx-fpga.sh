if devices 10ee: 1d0f:1042 1d0f:f010; then
	RELEASE=202210.2.13.466

	# InAccel runtime
	INACCEL_FPGA=2.2.1

	. /etc/os-release

	if [ ${ID} = amzn ]; then
		yum makecache
		yum install -y ca-certificates wget

		# Download Xilinx FPGA packages
		wget -O xrt.rpm "https://github.com/inaccel/driver/releases/download/xilinx-fpga-${RELEASE}/xrt-${RELEASE}_${ID}${VERSION_ID}-1.x86_64.rpm"
		if [ ${CLOUD_PROVIDER:-} ]; then
			wget -O xrt-${CLOUD_PROVIDER}.rpm "https://github.com/inaccel/driver/releases/download/xilinx-fpga-${RELEASE}/xrt-${CLOUD_PROVIDER}-${RELEASE}_${ID}${VERSION_ID}-1.x86_64.rpm"
		fi

		# Download InAccel runtime
		wget -O inaccel-fpga.rpm "https://dl.cloudsmith.io/public/inaccel/stable/rpm/any-distro/any-version/x86_64/inaccel-fpga-${INACCEL_FPGA}-1.x86_64.rpm"

		# Install Extra Packages for Enterprise Linux (EPEL)
		amazon-linux-extras install -y epel

		# Install Kernel Headers (required by Xilinx FPGA packages)
		yum install -y kernel-devel-$(uname -r) kernel-headers-$(uname -r)

		# Install Xilinx FPGA packages
		if ! yum list installed xrt; then
			yum install -y ./xrt.rpm
			if [ ${CLOUD_PROVIDER:-} ]; then
				yum install -y ./xrt-${CLOUD_PROVIDER}.rpm
			fi
		else
			yum upgrade -y ./xrt.rpm
			if [ ${CLOUD_PROVIDER:-} ]; then
				yum upgrade -y ./xrt-${CLOUD_PROVIDER}.rpm
			fi
		fi

		# Install InAccel runtime
		if ! yum list installed inaccel-fpga; then
			yum install -y ./inaccel-fpga.rpm
		else
			yum upgrade -y ./inaccel-fpga.rpm
		fi
	elif [ ${ID} = centos ]; then
		if [ ${VERSION_ID} -eq 8 ]; then
			sed -e "s|mirrorlist=|#mirrorlist=|g" -e "s|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g" -i /etc/yum.repos.d/CentOS-*
		fi

		setenforce 0

		yum makecache
		yum install -y ca-certificates wget

		# Download Xilinx FPGA packages
		wget -O xrt.rpm "https://github.com/inaccel/driver/releases/download/xilinx-fpga-${RELEASE}/xrt-${RELEASE}_${ID}${VERSION_ID}-1.x86_64.rpm"
		if [ ${CLOUD_PROVIDER:-} ]; then
			wget -O xrt-${CLOUD_PROVIDER}.rpm "https://github.com/inaccel/driver/releases/download/xilinx-fpga-${RELEASE}/xrt-${CLOUD_PROVIDER}-${RELEASE}_${ID}${VERSION_ID}-1.x86_64.rpm"
		fi

		# Download InAccel runtime
		wget -O inaccel-fpga.rpm "https://dl.cloudsmith.io/public/inaccel/stable/rpm/any-distro/any-version/x86_64/inaccel-fpga-${INACCEL_FPGA}-1.x86_64.rpm"

		VERSION=$(cat /etc/centos-release | cut -d " " -f 4)
		MAJOR_VERSION=$(echo ${VERSION} | cut -d . -f 1)
		MINOR_VERSION=$(echo ${VERSION} | cut -d . -f 2)

		if [ ${MAJOR_VERSION} -eq 8 ]; then
			# CentOS 8 Vault
			VAULT=https://vault.centos.org/${VERSION}/BaseOS/x86_64/os/Packages

			if [ ${MINOR_VERSION} -ge 3 ]; then
				APPSTREAM=appstream
				POWERTOOLS=powertools
			else
				APPSTREAM=AppStream
				POWERTOOLS=PowerTools
			fi
		else
			# CentOS Vault
			VAULT=https://vault.centos.org/${VERSION}/updates/x86_64/Packages
		fi

		# Install Extra Packages for Enterprise Linux (EPEL)
		yum install -y epel-release

		# Install Kernel Headers (required by Xilinx FPGA packages)
		if ! yum install -y kernel-devel-$(uname -r) kernel-headers-$(uname -r); then
			# Kernel Headers not found, retry using the CentOS Vault
			yum install -y ${VAULT}/kernel-devel-$(uname -r).rpm ${VAULT}/kernel-headers-$(uname -r).rpm
		fi

		# Install Xilinx FPGA packages
		if ! yum list installed xrt; then
			yum install -y ${APPSTREAM:+--enablerepo=${APPSTREAM}} ${POWERTOOLS:+--enablerepo=${POWERTOOLS}} ./xrt.rpm
			if [ ${CLOUD_PROVIDER:-} ]; then
				yum install -y ${APPSTREAM:+--enablerepo=${APPSTREAM}} ${POWERTOOLS:+--enablerepo=${POWERTOOLS}} ./xrt-${CLOUD_PROVIDER}.rpm
			fi
		else
			yum upgrade -y ${APPSTREAM:+--enablerepo=${APPSTREAM}} ${POWERTOOLS:+--enablerepo=${POWERTOOLS}} ./xrt.rpm
			if [ ${CLOUD_PROVIDER:-} ]; then
				yum upgrade -y ${APPSTREAM:+--enablerepo=${APPSTREAM}} ${POWERTOOLS:+--enablerepo=${POWERTOOLS}} ./xrt-${CLOUD_PROVIDER}.rpm
			fi
		fi

		# Install InAccel runtime
		if ! yum list installed inaccel-fpga; then
			yum install -y ./inaccel-fpga.rpm
		else
			yum upgrade -y ./inaccel-fpga.rpm
		fi

		setenforce 1
	elif [ ${ID} = ubuntu ]; then
		export DEBIAN_FRONTEND=noninteractive

		apt update
		apt install -y ca-certificates wget

		# Download Xilinx FPGA packages
		wget -O xrt.deb "https://github.com/inaccel/driver/releases/download/xilinx-fpga-${RELEASE}/xrt_${RELEASE}_${ID}${VERSION_ID}_amd64.deb"
		if [ ${CLOUD_PROVIDER:-} ]; then
			wget -O xrt-${CLOUD_PROVIDER}.deb "https://github.com/inaccel/driver/releases/download/xilinx-fpga-${RELEASE}/xrt-${CLOUD_PROVIDER}_${RELEASE}_${ID}${VERSION_ID}_amd64.deb"
		fi

		# Download InAccel runtime
		wget -O inaccel-fpga.deb "https://dl.cloudsmith.io/public/inaccel/stable/deb/any-distro/pool/any-version/main/i/in/inaccel-fpga_${INACCEL_FPGA}/inaccel-fpga_${INACCEL_FPGA}_amd64.deb"

		# Install Linux Extra Modules (required by Xilinx FPGA packages)
		apt install -y linux-modules-extra-$(uname -r)

		# Install Xilinx FPGA packages
		apt install -o Dpkg::Options::=--refuse-downgrade -y --allow-downgrades ./xrt.deb
		if [ ${CLOUD_PROVIDER:-} ]; then
			apt install -o Dpkg::Options::=--refuse-downgrade -y --allow-downgrades ./xrt-${CLOUD_PROVIDER}.deb
		fi

		# Install InAccel runtime
		apt install -o Dpkg::Options::=--refuse-downgrade -y --allow-downgrades ./inaccel-fpga.deb
	fi
fi
