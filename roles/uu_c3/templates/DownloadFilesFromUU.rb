# gem install uu_os --source=https://gems.plus4u.net

require 'uu_os'

UU::OS::Security::Session.login '{{ uu_login_file_path }}'

cmd_pack_uri = 'ues:UU-BT:UU-CLOUDG01-C3/APPBOX-{{ uu_c3_appbox_version }}:UU.C3/CMD-PACK'
dockerfiles_pack_uri = 'ues:UU-BT:UU-CLOUDG01-C3/APPBOX-{{ uu_c3_appbox_version }}:UU.C3/DOCKERFILES-PACK'
scripts_pack_uri = 'ues:UU-BT:UU-CLOUDG01-C3/APPBOX-{{ uu_c3_appbox_version }}:UU.C3/SCRIPTS-PACK'

cmd_pack = UU::OS::Attachment.get_attachment_data(cmd_pack_uri)
File.write('{{ uu_c3_base_folder }}/{{ uu_c3_appbox_version }}/uu_c3-cmd-{{ uu_c3_appbox_version }}.war', cmd_pack.data.read)

dockerfiles_pack_data = UU::OS::Attachment.get_attachment_data(dockerfiles_pack_uri)
File.write('{{ uu_c3_base_folder }}/{{ uu_c3_appbox_version }}/uu_c3-dockerfiles-{{ uu_c3_appbox_version }}.zip', dockerfiles_pack_data.data.read)

scripts_pack_data = UU::OS::Attachment.get_attachment_data(scripts_pack_uri)
File.write('{{ uu_c3_base_folder }}/{{ uu_c3_appbox_version }}/uu_c3-scripts-{{ uu_c3_appbox_version }}.zip', scripts_pack_data.data.read)
