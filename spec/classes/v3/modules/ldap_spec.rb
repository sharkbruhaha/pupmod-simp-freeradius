require 'spec_helper'

default_module_content = <<-EOF
#
# This file auto-generated by Puppet. Changes made by hand will be
# automatically over-written on the next Puppet run.
#
# To see available options and notes for the FreeRADIUS LDAP module,
# look in /etc/raddb/mods-available/ldap
#
ldap {
  server = 'ldap://foo.bar.baz'
  port = 389
  identity = 'dn=test,ou=foo,dc=bar,dc=baz'
  password = 'password'
  base_dn = 'ou=foo,dc=bar,dc=baz'

  update {
    control:Password-With-Header += 'userPassword'
  }

  user {
    base_dn = 'ou=foo,dc=bar,dc=baz'
    filter = "(uid=%{%{Stripped-User-Name}:-%{User-Name}})"
  }

  group {
    base_dn = 'ou=foo,dc=bar,dc=baz'
    filter = "(objectclass=radiusprofile)"
    name_attribute = cn
    membership_filter = "(|(&(objectClass=GroupOfNames)(member=%{control:Ldap-UserDn}))(&(objectClass=GroupOfUniqueNames)(uniquemember=%{control:Ldap-UserDn})))"
    membership_attribute = 'memberOf'
    cacheable_name = 'no'
    cacheable_dn = 'no'
  }

  profile {
    filter = "(objectclass=radiusprofile)"
  }

  client {
    base_dn = 'ou=foo,dc=bar,dc=baz'
    filter = "(objectClass=frClient)"

    attribute {
      identifier = 'radiusClientIdentifier'
      secret = 'radiusClientSecret'
    }
  }

  accounting {
    reference = "%{tolower:type.%{Acct-Status-Type}}"

    type {
      start {
        update {
          description := "Online at %S"
        }
      }

      interim-update {
        update {
          description := "Last seen at %S"
        }
      }

      stop {
        update {
          description := "Offline at %S"
        }
      }
    }
  }

  post-auth {
    update {
      description := "Authenticated at %S"
    }
  }

  options {
    dereference = never
    chase_referrals = no
    rebind = no
    res_timeout = 4
    srv_timelimit = 3
    net_timeout = 1
    idle = 60
    probes = 3
    interval = 3
  }

  tls {
    start_tls = yes
    ca_path = /etc/pki/simp_apps/freeradius/x509/cacerts/
    certificate_file = /etc/pki/simp_apps/freeradius/x509/public/foo.example.com.pub
    private_key_file = /etc/pki/simp_apps/freeradius/x509/private/foo.example.com.pem
    random_file = /dev/urandom
    require_cert = 'demand'
  }

  pool {
    start = 5
    min = 4
    max = 10
    spare = 3
    uses = 0
    retry_delay = 30
    lifetime = 0
    idle_timeout = 60
  }
}
EOF

nondefault_module_content = <<-EOF
#
# This file auto-generated by Puppet. Changes made by hand will be
# automatically over-written on the next Puppet run.
#
# To see available options and notes for the FreeRADIUS LDAP module,
# look in /etc/raddb/mods-available/ldap
#
ldap {
  server = 'ldap://foo.bar.baz'
  port = 1389
  identity = 'dn=test,ou=foo,dc=bar,dc=baz'
  password = 'password'
  base_dn = 'ou=foo,dc=bar,dc=baz'

  update {
    control:Password-With-Header += 'userPassword'
  }

  user {
    base_dn = 'ou=foo,dc=bar,dc=baz'
    filter = "test(uid=%{%{Stripped-User-Name}:-%{User-Name}})"
    scope = 'sub'
    access_positive = no
    access_attribute = 'user_access_attribute'
  }

  group {
    base_dn = 'ou=foo,dc=bar,dc=baz'
    filter = "test(objectclass=radiusprofile)"
    scope = 'one'
    name_attribute = testcn
    membership_filter = "test_membership_filter"
    membership_attribute = 'testmemberOf'
    cacheable_name = 'yes'
    cacheable_dn = 'yes'
  }

  profile {
    filter = "test(objectclass=radiusprofile)"
    default = 'default_profile'
    attribute = 'profile_attribute'
  }

  client {
    base_dn = 'ou=foo,dc=bar,dc=baz'
    filter = "test(objectClass=frClient)"
    scope = 'base'

    attribute {
      identifier = 'testradiusClientIdentifier'
      secret = 'testradiusClientSecret'
      shortname = 'shortname'
      nas_type = 'cisco'
      virtual_server = 'virtual_server'
    }
  }

  accounting {
    reference = "%{tolower:type.%{Acct-Status-Type}}"

    type {
      start {
        update {
          description := "Online at %S"
        }
      }

      interim-update {
        update {
          description := "Last seen at %S"
        }
      }

      stop {
        update {
          description := "Offline at %S"
        }
      }
    }
  }

  post-auth {
    update {
      description := "Authenticated at %S"
    }
  }

  options {
    dereference = always
    chase_referrals = yes
    rebind = yes
    res_timeout = 14
    srv_timelimit = 13
    net_timeout = 11
    idle = 160
    probes = 13
    interval = 13
    ldap_debug = ldap_debug
  }

  tls {
    start_tls = no
    ca_path = /etc/pki/simp_apps/freeradius/x509/cacerts/
    certificate_file = /etc/pki/simp_apps/freeradius/x509/public/foo.example.com.pub
    private_key_file = /etc/pki/simp_apps/freeradius/x509/private/foo.example.com.pem
    random_file = /dev/test
    require_cert = 'nocert'
  }

  pool {
    start = 15
    min = 14
    max = 110
    spare = 13
    uses = 10
    retry_delay = 130
    lifetime = 10
    idle_timeout = 160
  }
}
EOF

describe 'freeradius::v3::modules::ldap' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      let(:facts) { facts }
      let(:pre_condition) {'include "freeradius"'}

      context 'with default params' do
        let(:facts) { facts.merge({:radius_version => '3'})}
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_class('freeradius::v3::modules::ldap') }
        it { is_expected.to create_file('/etc/raddb/mods-enabled/ldap').with_content(default_module_content)}
      end

      context 'with params' do
        let(:facts) { facts.merge({:radius_version => '3'})}
        let(:params){{
          :base_filter                       =>  'test(objectclass=radiusprofile)',
          :client_scope                      =>  'base',
          :client_attribute_identifier       =>  'testradiusClientIdentifier',
          :client_attribute_secret           =>  'testradiusClientSecret',
          :client_attribute_shortname        =>  'shortname',
          :client_attribute_nas_type         =>  'cisco',
          :client_attribute_virtual_server   =>  'virtual_server',
          :client_filter                     =>  'test(objectClass=frClient)',
          :default_profile                   =>  'default_profile',
          :group_scope                       =>  'one',
          :group_name_attribute              =>  'testcn',
          :group_membership_filter           =>  'test_membership_filter',
          :group_membership_attribute        =>  'testmemberOf',
          :group_cacheable_name              =>  true,
          :group_cacheable_dn                =>  true,
          :ldap_connections_number           =>  15,
          :ldap_debug                        =>  'ldap_debug',
          :ldap_timeout                      =>  14,
          :ldap_timelimit                    =>  13,
          :options_chase_referrals           =>  true,
          :options_dereference               =>  'always',
          :options_idle                      =>  160,
          :options_interval                  =>  13,
          :options_net_timeout               =>  11,
          :options_probes                    =>  13,
          :options_rebind                    =>  true,
          :pool_start                        =>  15,
          :pool_min                          =>  14,
          :pool_max                          =>  110,
          :pool_spare                        =>  13,
          :pool_uses                         =>  10,
          :pool_lifetime                     =>  10,
          :pool_idle_timeout                 =>  160,
          :port                              =>  1389,
          :profile_attribute                 =>  'profile_attribute',
          :random_file                       =>  '/dev/test',
          :require_cert                      =>  'nocert',
          :retry_delay                       =>  130,
          :start_tls                         =>  false,
          :user_access_attribute             =>  'user_access_attribute',
          :user_access_positive              =>  false,
          :user_filter                       =>  'test(uid=%{%{Stripped-User-Name}:-%{User-Name}})',
          :user_scope                        =>  'sub',
        }}
        it { is_expected.to create_file('/etc/raddb/mods-enabled/ldap').with_content(nondefault_module_content)}
      end

    end
  end
end
