
# Copyright 2017-present Open Networking Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


-----------------------------------------------------------------------------
-- $Id: 83a455e620e5ac9603c659697ce9c756c9ccddb1 $                 	   --
--                                                                         --
--  schema.sql                       rlm_sql - FreeRADIUS SQLite Module    --
--                                                                         --
--     Database schema for SQLite rlm_sql module                           --
--                                                                         --
--     To load:                                                            --
--         mysql -uroot -prootpass radius < schema.sql                     --
--                                                                         --
-----------------------------------------------------------------------------

--
-- Table structure for table 'radacct'
--
CREATE TABLE radacct (
  radacctid bigint(21) PRIMARY KEY,
  acctsessionid varchar(64) NOT NULL default '',
  acctuniqueid varchar(32) NOT NULL default '',
  username varchar(64) NOT NULL default '',
  groupname varchar(64) NOT NULL default '',
  realm varchar(64) default '',
  nasipaddress varchar(15) NOT NULL default '',
  nasportid varchar(15) default NULL,
  nasporttype varchar(32) default NULL,
  acctstarttime datetime NULL default NULL,
  acctupdatetime datetime NULL default NULL,
  acctstoptime datetime NULL default NULL,
  acctinterval int(12) default NULL,
  acctsessiontime int(12) default NULL,
  acctauthentic varchar(32) default NULL,
  connectinfo_start varchar(50) default NULL,
  connectinfo_stop varchar(50) default NULL,
  acctinputoctets bigint(20) default NULL,
  acctoutputoctets bigint(20) default NULL,
  calledstationid varchar(50) NOT NULL default '',
  callingstationid varchar(50) NOT NULL default '',
  acctterminatecause varchar(32) NOT NULL default '',
  servicetype varchar(32) default NULL,
  framedprotocol varchar(32) default NULL,
  framedipaddress varchar(15) NOT NULL default ''
);

CREATE UNIQUE INDEX acctuniqueid ON radacct(acctuniqueid);
CREATE INDEX username ON radacct(username);
CREATE INDEX framedipaddress ON radacct (framedipaddress);
CREATE INDEX acctsessionid ON radacct(acctsessionid);
CREATE INDEX acctsessiontime ON radacct(acctsessiontime);
CREATE INDEX acctstarttime ON radacct(acctstarttime);
CREATE INDEX acctinterval ON radacct(acctinterval);
CREATE INDEX acctstoptime ON radacct(acctstoptime);
CREATE INDEX nasipaddress ON radacct(nasipaddress);

--
-- Table structure for table 'radcheck'
--
CREATE TABLE radcheck (
  id int(11) PRIMARY KEY,
  username varchar(64) NOT NULL default '',
  attribute varchar(64)  NOT NULL default '',
  op char(2) NOT NULL DEFAULT '==',
  value varchar(253) NOT NULL default ''
);
CREATE INDEX check_username ON radcheck(username);

--
-- Table structure for table 'radgroupcheck'
--
CREATE TABLE radgroupcheck (
  id int(11) PRIMARY KEY,
  groupname varchar(64) NOT NULL default '',
  attribute varchar(64)  NOT NULL default '',
  op char(2) NOT NULL DEFAULT '==',
  value varchar(253)  NOT NULL default ''
);
CREATE INDEX check_groupname ON radgroupcheck(groupname);

--
-- Table structure for table 'radgroupreply'
--
CREATE TABLE radgroupreply (
  id int(11) PRIMARY KEY,
  groupname varchar(64) NOT NULL default '',
  attribute varchar(64)  NOT NULL default '',
  op char(2) NOT NULL DEFAULT '=',
  value varchar(253)  NOT NULL default ''
);
CREATE INDEX reply_groupname ON radgroupreply(groupname);

--
-- Table structure for table 'radreply'
--
CREATE TABLE radreply (
  id int(11) PRIMARY KEY,
  username varchar(64) NOT NULL default '',
  attribute varchar(64) NOT NULL default '',
  op char(2) NOT NULL DEFAULT '=',
  value varchar(253) NOT NULL default ''
);
CREATE INDEX reply_username ON radreply(username);

--
-- Table structure for table 'radusergroup'
--
CREATE TABLE radusergroup (
  username varchar(64) NOT NULL default '',
  groupname varchar(64) NOT NULL default '',
  priority int(11) NOT NULL default '1'
);
CREATE INDEX usergroup_username ON radusergroup(username);

--
-- Table structure for table 'radpostauth'
--
CREATE TABLE radpostauth (
  id int(11) PRIMARY KEY,
  username varchar(64) NOT NULL default '',
  pass varchar(64) NOT NULL default '',
  reply varchar(32) NOT NULL default '',
  authdate timestamp NOT NULL
);

--
-- Table structure for table 'nas'
--
CREATE TABLE nas (
  id int(11) PRIMARY KEY,
  nasname varchar(128) NOT NULL,
  shortname varchar(32),
  type varchar(30) DEFAULT 'other',
  ports int(5),
  secret varchar(60) DEFAULT 'secret' NOT NULL,
  server varchar(64),
  community varchar(50),
  description varchar(200) DEFAULT 'RADIUS Client'
);
CREATE INDEX nasname ON nas(nasname);
