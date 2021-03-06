
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


--
-- Table structure for table 'radippool'
--
CREATE TABLE  (
  id                    int(11) PRIMARY KEY,
  pool_name             varchar(30) NOT NULL,
  framedipaddress       varchar(15) NOT NULL default '',
  nasipaddress          varchar(15) NOT NULL default '',
  calledstationid       VARCHAR(30) NOT NULL,
  callingstationid      VARCHAR(30) NOT NULL,
  expiry_time           DATETIME NULL default NULL,
  username              varchar(64) NOT NULL default '',
  pool_key              varchar(30) NOT NULL
);

CREATE INDEX radippool_poolname_expire ON radippool(pool_name, expiry_time);
CREATE INDEX radippool_framedipaddress ON radippool(framedipaddress);
CREATE INDEX radippool_nasip_poolkey_ipaddress ON radippool(nasipaddress, pool_key, framedipaddress);
