# == Class: backup
#
# This class creates a backup script and corresponding cron job to backup
# the specified directories and/or files on a daily or hourly basis.
#
# === Parameters
#
# [*aws_access_key*]
#
# The AWS access key to be used.  Required.
# If you wanted to, you could set your corporate keys as the defaults.
#
# [*aws_secret_key*]
#
# The AWS secret key to be used.  Required.
# If you wanted to, you could set your corporate keys as the defaults.
#
# [*directories*]
#
# An array of strings indicating the directories to backup.
# Defaults to the /etc direcotory.
#
# [*files*]
#
# An array of strings indicating the files to backup.
# Defauts to an empty array.
#
# [*frequency*]
#
# How often the script should run.  Valid values are daily or hourly.
# Defaults to daily.
#
# [*bucket*]
#
# Name of the AWS bucket that we should store our data too.
# Note: AWS bucket names must be unique for all of AWS, not just your account
#
# [*bucket_location*]
#
# Sets the AWS region that the bucket should be stored in.
# Defaults to "us-west"
#
# === Examples
#
#  class { 'backup':
#     aws_access_key => "skdfjasdf",
#     aws_secret_key => "something",
#    directories => [ '/etc', '/opt/app/' ],
#  }
#
# === Authors
#
# Author Name <marc@runkel.org>
#
# === Copyright
#
# Copyright 2015
#
class backup (
  $aws_access_key = '',
  $aws_secret_key = '',
  $directories = ['/etc'],
  $files = [],
  $frequency = 'daily',
  $bucket = 'xxxxxxxx-backups',
  $bucket_lcation = 'us-west',
)
{

  if !($frequency in ['daily', 'hourly']) {
    fail ('Frequency must be daily or hourly')
  }

  if $frequency == 'daily' {
    $antifreq = 'hourly'
  } else {
    $antifreq = 'daily'
  }

  #install python-magic so that s3cmd doesn't whine
  package {'python-magic':
    ensure => installed,
  }
  include '::s3cmd'

  # install s3cmd configuration
  s3cmd::config { 'root':
    aws_access_key  => $aws_access_key,
    aws_secret_key  => $aws_secret_key,
    bucket_location => $bucket_location,
  }

  file {'/usr/local/sbin/backup.sh':
    ensure  => present,
    content => template ('backup/backup-script.erb'),
    owner   => root,
    group   => root,
    mode    => '0755',
  }

  # create symlink for the cron entry
  file { "/etc/cron.${frequency}/backup":
    ensure => link,
    target => '/usr/local/sbin/backup.sh',
  }

  # make sure to remove the other entry
  file { "/etc/cron.${antifreq}/backup":
    ensure => absent,
  }

}
