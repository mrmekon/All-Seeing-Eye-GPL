SQLite format 3   @        
                                                             -�   �    	�                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               � ���c�                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              q )!%);Jessica Balmes102030409-14-1986770-843-100750 Lakeland DrN/AAtlantaGAvaGoogleSome notes on something !        Dave Foley1234567* 5!        William S. Burroughs2020202020% +!       King Henry VIII1111111111) -'        Trevor S Bentley1118063645744
   � �����                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      10203041234567!2020202020!1111111111'1118063645744   � �                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
   � �                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   � ����                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             xi�$Q�T0Q�T0ևQ�T0xi�$   � ��                                                                                                                                                                                                                                                                                                                                                                                                   ��tablecustomerscustomersCREATE TABLE customers (
  customer_id INTEGER PRIMARY KEY ASC,
  name TEXT NOT NULL,
  barcode TEXT NOT NULL,
  birthday TEXT,
  phone TEXT,
  street_1 TEXT,
  street_2 TEXT,
  city TEXT,
  state TEXT,
  zipcode INTEGER,
  referral_site TEXT
, notes TEXT)X%{indexcustomer_idxcustomersCREATE UNIQUE INDEX customer_idx ON customers (barcode)�p99�{tablecustomer_reward_levelscustomer_reward_levelsCREATE TABLE customer_reward_levels (
customer_id INTEGER NOT NULL,
  level INTEGER NOT NULL,
  credit INTEGER NOT NULL,
  FOREIGN KEY(customer_id) REFERENCES customers(customer_id)
)
   � ����                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
Q�T0ևxi�$   b -��b                                                                                                                                                                                                                                                                                                                                                  �H�ctablescan_logscan_log
CREATE TABLE scan_log (
customer_id INTEGER NOT NULL,
  time TEXT NOT NULL,
  reward_level INTEGER NOT NULL,
  FOREIGN KEY(customer_id) REFERENCES customers(customer_id)
)-9�%indexreward_level_idxcustomer_reward_levelsCREATE UNIQUE INDEX reward_level_idx ON customer_reward_levels (customer_id)�n�+tablereferralsreferralsCREATE TABLE referrals (
  referrer INTEGER NOT NULL,
  customer_id INTEGER NOT NULL,
  FOREIGN KEY(referrer) REFERENCES customers(customer_id),
  FOREIGN KEY(customer_id) REFERENCES customers(customer_id)
)_'�indexreferrals_idxreferralsCREATE UNIQUE INDEX referrals_idx ON referrals (customer_id)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              