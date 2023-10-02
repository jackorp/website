FROM registry.fedoraproject.org/fedora
MAINTAINER Developer-portal <developer-portal@lists.fedoraproject.org>

ENV APPDIR="/opt/developerportal/website/"
ADD . "${APPDIR}"
WORKDIR "${APPDIR}"

ENV PKGS=" \
    autoconf \
    gcc \
    git \
    make \
    python-feedparser \
    ruby-devel \
    rubygem-nokogiri \
		rubygem-webrick \
    libxml2-devel \
    libxslt-devel \
    "

RUN set -x && \
    echo "Set disable_coredump false" >> /etc/sudo.conf && \
    dnf install ${PKGS} -y && \
    dnf group install "C Development Tools and Libraries" -y && \
    dnf autoremove -y && \
    dnf clean all -y && \
    \
    bundle config build.nokogiri --use-system-libraries && \
    bundle install && \
    \
    git reset --hard origin/master && \
    git submodule update --init --recursive && \
    pushd content && \
    git reset --hard origin/master && \
    popd && \
    \
    jekyll build

# Jekyll runs on port 4000 by default
EXPOSE 4000

# Update the content on every run of the container
#ENTRYPOINT LANG=en_US.UTF-8 bundle exec bash -i "$@"
CMD jekyll serve --force_polling -H 0.0.0.0 -l -I -w
