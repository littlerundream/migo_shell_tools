# Create the hosts script
echo -e "$hosts" > hosts


# Create the install-s3fs.yaml script
cat >install-s3fs.yaml <<'END_SCRIPT'
---
- name: Install s3-fuse
  hosts: all
  become: true
  gather_facts: false
 
  tasks:
    - name: Install dependencies
      yum:
        name: "{{ item }}"
        state: present
      with_items:
        - gcc
        - gcc-c++
        - fuse
        - fuse-devel
        - libcurl-devel
        - libxml2-devel
        - openssl-devel
        - automake
        - autoconf
        - libtool
        - git
 
    - name: Create /tmp/s3fs-fuse directory
      file:
        path: /tmp/s3fs-fuse
        state: directory
        mode: '0755'
 
    - name: Download the s3fs-fuse tar.gz file
      get_url:
        url: "{{ af_download_url }}"
        dest: /tmp/s3fs-fuse.tar.gz
        headers:
          Authorization: "Basic {{ af_download_token }}"
 
    - name: Extract s3fs-fuse tar.gz file
      unarchive:
        src: /tmp/s3fs-fuse.tar.gz
        dest: /tmp/s3fs-fuse
        remote_src: true
        mode: '0755'
 
    - name: Build and install s3fs-fuse
      shell: |
        cd /tmp/s3fs-fuse/s3fs-fuse-1.93
        ./autogen.sh
        ./configure
        make
        sudo make install
 
    - name: Create mount point directory
      file:
        path: /mnt/s3fs
        state: directory
        mode: '0755'
 
    - name: Update fuse.conf
      become: true
      command: sudo sed -i 's/# user_allow_other/user_allow_other/g' /etc/fuse.conf
 
    - name: Mount s3fs
      shell: |
        echo "{{ s3_access_key }}:{{ s3_secret_key }}" > /etc/passwd-s3fs
        chmod 600 /etc/passwd-s3fs
        /usr/local/bin/s3fs {{ s3_bucket_name }} /mnt/s3fs -o compat_dir -o use_wtf8 -o listobjectsv2  -o passwd_file=/etc/passwd-s3fs -o url={{ s3_url }} -o use_path_request_style -o allow_other,uid=66666,gid=66666 -o nonempty
 
    - name: Add s3fs mount to fstab
      lineinfile:
        path: /etc/fstab
        line: "{{ s3_bucket_name }} /mnt/s3fs fuse.s3fs uid=66666,gid=66666,_netdev,nonempty,compat_dir,allow_other,use_wtf8,use_path_request_style,url={{ s3_url }} 0 0"
        state: present
END_SCRIPT

# Generate the download token
af_download_token=$(echo -n "$af_username:$af_password" | base64)

# Run the ansible playbook
ansible-playbook -i hosts -e "s3_access_key=$s3_access_key" -e "s3_secret_key=$s3_secret_key" \
-e "s3_bucket_name=$s3_bucket_name" -e "s3_url=$s3_url" -e "af_download_url=$af_download_url" \
-e "af_download_token=$af_download_token" install-s3fs.yaml