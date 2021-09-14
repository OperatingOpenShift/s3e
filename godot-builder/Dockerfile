FROM quay.io/buildah/stable

LABEL io.openshift.s2i.scripts-url="image:///usr/libexec/s2i"

RUN dnf install -y unzip nginx
RUN curl -L https://github.com/godotengine/godot/releases/download/3.3.3-stable/Godot_v3.3.3-stable_linux_headless.64.zip -o /tmp/godot.zip
RUN unzip /tmp/godot.zip
RUN curl -L https://downloads.tuxfamily.org/godotengine/3.3.3/Godot_v3.3.3-stable_export_templates.tpz -o /tmp/export_templates.zip
RUN mv Godot_* /usr/bin/godot
RUN mkdir -p /root/.local/share/godot/templates/3.3.3.stable/
WORKDIR  /root/.local/share/godot/templates/3.3.3.stable/
RUN unzip -j /tmp/export_templates.zip templates/webassembly_release.zip templates/webassembly_debug.zip
COPY nginx.conf /etc/nginx/nginx.conf
COPY bin /usr/libexec/s2i

EXPOSE 8080
