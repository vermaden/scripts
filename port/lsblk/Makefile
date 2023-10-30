PORTNAME=	lsblk
PORTVERSION=	1.0
PORTREVISION=	0
CATEGORIES=	sysutils
MASTER_SITES=	\
		https://github.com/vermaden/scripts/raw/master/release/

MAINTAINER=	vermaden@interia.pl
COMMENT=	Lists information about block devices in the system.

LICENSE=	BSD2CLAUSE

# USE_GITHUB=	yes
# GH_ACCOUNT=	vermaden

NO_BUILD=	YES
NO_ARCH=	YES

CONFLICTS_INSTALL=	

PLIST_FILES=	sbin/${PORTNAME}

do-install:
	${INSTALL_SCRIPT} ${WRKSRC}/lsblk.sh \
	    ${STAGEDIR}${PREFIX}/sbin/${PORTNAME}

.include <bsd.port.mk>

