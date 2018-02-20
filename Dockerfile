FROM alpine:3.7

ENV USER alpine
ENV HOME /home/$USER
ENV TERM=xterm-256color

WORKDIR $HOME

RUN apk update && apk upgrade && \
    apk --no-cache add zsh bash tzdata shadow curl go tmux openssl openssh neovim mosh-server git

# Create the user based on ENV, with a long random password
RUN addgroup -S $USER && \
    adduser -D -S -h $HOME -s /bin/zsh -G $USER $USER && \
    echo $USER:$(openssl rand -base64 60) | chpasswd

# Generate ssh keys
RUN /usr/bin/ssh-keygen -A

# Tighten up the ssh setup a little
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
RUN sed -i "s/#PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config
RUN echo 'UseDNS no' >> /etc/ssh/sshd_config
RUN echo 'AllowUsers '$USER >> /etc/ssh/sshd_config

COPY build/zshrc $HOME/.zshrc
COPY build/config $HOME/.config
COPY build/init.sh /etc/my_init.d/

#Make the init script executable
RUN chmod +x /etc/my_init.d/*.sh

# Fix the permissions for ssh
RUN mkdir -p $HOME/.ssh
RUN chmod -R 700 $HOME/.ssh

# Add fzf, used for nicer command history
RUN git clone https://github.com/junegunn/fzf.git $HOME/.config/fzf
RUN /bin/bash $HOME/.config/fzf/install

# Makes the terminal come alive with colors
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.config/zsh/zsh-syntax-highlighting

#      ssh mosh
EXPOSE 22 60001/udp

CMD ["/etc/my_init.d/init.sh"]
