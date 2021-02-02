# gem install uu_os --source=https://gems.plus4u.net

require 'uu_os'

UU::OS::Security::Session.login '{{ uu_login_file_path }}'

cmd_pack_uri = 'ues:UU-BT:UU-CLOUDG01-OPERATIONREGISTRY/APPBOX-{{ uu_or_appbox_version }}:UU.OPERATION_REGISTRY/CMD-PACK'
dockerfiles_pack_uri = 'ues:UU-BT:UU-CLOUDG01-OPERATIONREGISTRY/APPBOX-{{ uu_or_appbox_version }}:UU.OPERATION_REGISTRY/DOCKERFILES-PACK'

cmd_pack = UU::OS::Attachment.get_attachment_data(cmd_pack_uri)
File.write('{{ uu_or_base_folder }}/{{ uu_or_appbox_version }}/uu_operation_registry-cmd-{{ uu_or_appbox_version }}.war', cmd_pack.data.read)

dockerfiles_pack_data = UU::OS::Attachment.get_attachment_data(dockerfiles_pack_uri)
File.write('{{ uu_or_base_folder }}/{{ uu_or_appbox_version }}/uu_operation_registry-dockerfiles-{{ uu_or_appbox_version }}.zip', dockerfiles_pack_data.data.read)
