import socket
from threading import Thread
import ast
from time import sleep
from datetime import datetime

class Server:
  def __init__(self, server_port):
    self.port = server_port
    self.curr_seq = 0
    self.alive = True
    self.waiting_ack = set()
    self.offline_messages = {}
    if server_port < 1024 or server_port > 65535:
      print('[Error: given server port invalid]')
      return
    self.socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    self.socket.bind(('', int(server_port)))
    self.all_clients = {}
    listening_thread = Thread(target=self.listen)
    listening_thread.start()
  
  def handleCatchingup(self, message, address):
    # now check if there are offline messages and send them all
    if message['client_name'] in self.offline_messages:
      offline_message_upon_reg = {}
      offline_message_upon_reg['type'] = 'offline_message_upon_reg'
      offline_message_upon_reg['seq'] = self.curr_seq
      curr_seq = self.curr_seq
      self.curr_seq += 1
      offline_message_upon_reg['all_messages'] = self.offline_messages[message['client_name']]
      self.socket.sendto(str(offline_message_upon_reg).encode(), (address[0], int(address[1])))
      self.waiting_ack.add(curr_seq)
      sleep(0.1)
      # if succeeded in catching up with offline messages, notify the original senders
      if curr_seq not in self.waiting_ack:
        for each in self.offline_messages[message['client_name']]:
          if each['type'] == 'group':
            continue
          timestamp = each['timestamp']
          receiver = message['client_name']
          delivery_confirmation = {}
          delivery_confirmation['type'] = 'delivery_confirmation'
          delivery_confirmation['seq'] = self.curr_seq
          curr_seq = self.curr_seq
          self.curr_seq += 1
          delivery_confirmation['timestamp'] = timestamp
          delivery_confirmation['receiver'] = receiver
          self.waiting_ack.add(curr_seq)
          print('hihihi', each)
          if each['from'] == 'server':
            self.socket.sendto(str(delivery_confirmation).encode(), (self.all_clients[message['client_name']]['ip'],self.all_clients[message['client_name']]['port']))
          else:
            self.socket.sendto(str(delivery_confirmation).encode(), (self.all_clients[each['from']]['ip'],self.all_clients[each['from']]['port']))
          sleep(0.1)
          # if the original sender is inactive, then store the delivery confirmation for the sender
          if curr_seq in self.waiting_ack:
            stored_message = {}
            stored_message['from'] = 'server'
            stored_message['type'] = ['nongroup']
            stored_message['content'] = f'>>> [Offline Message sent at {timestamp} received by {receiver}.]'
            stored_message['timestamp'] = str(datetime.now())[:-7]
            if each['from'] in self.offline_messages:
              self.offline_messages[each['from']].append(stored_message)
            else:
              self.offline_messages[each['from']] = [stored_message]

            
        self.offline_messages.pop(message['client_name'])


      # else, set the receiver to inactive again
      else:
        self.all_clients[message['client_name']]['status'] = False
        print('>>> [Client table updated.]')
        print('>>> table: ', self.all_clients)
        broadcase_table_thread = Thread(target=self.broadcast_table)
        broadcase_table_thread.start()


  def listen(self):
    while True:
      message_and_address = self.socket.recvfrom(2048)
      # message = json.load(message_and_address[0].decode())
      message = ast.literal_eval(message_and_address[0].decode())
      address = message_and_address[1]
      if self.alive:
        # if the received message is an registration request from a client
        if message['type'] == 'registration':
          self.all_clients[message['client_name']] = {'ip': address[0], 'port': address[1], 'status': True}
          print('>>> [Client table updated.]')
          print('>>> table: ', self.all_clients)
          confirm_registration = {}
          confirm_registration['type'] = 'confirm_registration'
          confirm_registration['seq'] = message['seq']
          self.socket.sendto(str(confirm_registration).encode(), (address[0], int(address[1])))
          # now broadcast the updated table to clients
          broadcase_table_thread = Thread(target=self.broadcast_table)
          broadcase_table_thread.start()
          catch_up_thread = Thread(target=self.handleCatchingup, args=(message,address,))
          catch_up_thread.start()

        elif message['type'] == 'ack_upon_update':
          self.waiting_ack.remove(message['seq'])
        elif message['type'] == 'offline_message':
          # first still send an ack for receiving the offline message from the sender
          confirm_direct_offline = {}
          confirm_direct_offline['type'] = 'confirm_direct_offline_message_from_server'
          confirm_direct_offline['seq'] = message['seq']
          self.socket.sendto(str(confirm_direct_offline).encode(), (address[0], int(address[1])))
          send_to = message['to']
          # form the stored message, but whether to use it or not depends
          stored_message = {}
          stored_message['from'] = message['from']
          stored_message['type'] = 'nongroup'
          stored_message['content'] = message['content']
          stored_message['timestamp'] = message['timestamp']
          # if according to server's table, the receiver is active
          if self.all_clients[send_to]['status']:
            check_receiver = {}
            check_receiver['type'] = 'check_receiver'
            check_receiver['seq'] = self.curr_seq
            curr_seq = self.curr_seq
            self.curr_seq += 1
            self.socket.sendto(str(check_receiver).encode(), (self.all_clients[send_to]['ip'], self.all_clients[send_to]['port']))
            self.waiting_ack.add(curr_seq)
            sleep(0.1)
            # the receiver is actually active so need to notify the sender the error message and to resend the message
            if curr_seq not in self.waiting_ack:
              # tell the sender that receiver is not dead
              note_receiver_not_dead = {}
              note_receiver_not_dead['type'] = 'note_receiver_not_dead'
              note_receiver_not_dead['seq'] = self.curr_seq
              note_receiver_not_dead['receiver_name'] = send_to
              curr_seq = self.curr_seq
              self.curr_seq += 1
              self.socket.sendto(str(note_receiver_not_dead).encode(), (address[0], int(address[1])))

              # send the actual message to the receiver
              makeup_message_to_receiver = {}
              makeup_message_to_receiver['type'] = 'makeup_message_to_receiver'
              makeup_message_to_receiver['seq'] = self.curr_seq
              curr_seq = self.curr_seq
              self.curr_seq += 1
              makeup_message_to_receiver['from'] = message['from']
              makeup_message_to_receiver['timestamp'] = message['timestamp']
              makeup_message_to_receiver['content'] = message['content']
              self.socket.sendto(str(check_receiver).encode(), (self.all_clients[send_to]['ip'], self.all_clients[send_to]['port']))
              self.waiting_ack.add(curr_seq)
              sleep(0.1)
              if curr_seq not in self.waiting_ack:
                print(f'<<< [the receiver {send_to} is alive and message delivered]')
              else:
                self.all_clients[send_to]['status'] = False
                print('>>> [Client table updated.]')
                print('>>> table: ', self.all_clients)
                broadcase_table_thread = Thread(target=self.broadcast_table)
                broadcase_table_thread.start()
            # the receiver is indeed inactive
            else:
              self.all_clients[send_to]['status'] = False
              print('>>> [Client table updated.]')
              print('>>> table: ', self.all_clients)
              broadcase_table_thread = Thread(target=self.broadcast_table)
              broadcase_table_thread.start()
              if message['to'] in self.offline_messages:
                self.offline_messages[message['to']].append(stored_message)
              else:
                self.offline_messages[message['to']] = [stored_message]
              confirm_offline_message_save = {}
              confirm_offline_message_save['type'] = 'confirm_offline_message_save'
              confirm_offline_message_save['seq'] = self.curr_seq
              self.curr_seq += 1
              confirm_offline_message_save['timestamp'] = message['timestamp']
              self.socket.sendto(str(confirm_offline_message_save).encode(), (address[0], int(address[1])))
          # if according to server, the receiver is indeed dead, then save the message
          else:
            if message['to'] in self.offline_messages:
              self.offline_messages[message['to']].append(stored_message)
            else:
              self.offline_messages[message['to']] = [stored_message]
        elif message['type'] == 'confirm_receiver':
          self.waiting_ack.remove(message['seq'])
        elif message['type'] == 'confirm_makeup_message':
          self.waiting_ack.remove(message['seq'])
        elif message['type'] == 'confirm_offline_message_upon_reg':
          self.waiting_ack.remove(message['seq'])
        elif message['type'] == 'ack_upon_delivery_confirmation':
          self.waiting_ack.remove(message['seq'])
        elif message['type'] == 'group_message':
          confirm_group_message = {}
          confirm_group_message['type'] = 'confirm_group_message'
          confirm_group_message['seq'] = message['seq']
          self.socket.sendto(str(confirm_group_message).encode(), (address[0], int(address[1])))
          print('>>> [Client table updated.]')
          print('>>> table: ', self.all_clients)
          broadcase_group_message_thread = Thread(target=self.broadcast_group_message, args=(message,))
          broadcase_group_message_thread.start()
        elif message['type'] == 'ack_group_message':
          self.waiting_ack.remove(message['seq'])
          
          # print('all_off_line_messages: ', self.offline_messages)
          
        elif message['type'] == 'deregister':
          confirm_dereg = {}
          confirm_dereg['type'] = 'confirm_dereg'
          confirm_dereg['seq'] = message['seq']
          self.socket.sendto(str(confirm_dereg).encode(), (address[0], int(address[1])))
          self.all_clients[message['client_name']]['status'] = False
          print('>>> [Client table updated.]')
          print('>>> table: ', self.all_clients)
          broadcase_table_thread = Thread(target=self.broadcast_table)
          broadcase_table_thread.start()

  def broadcast_group_message(self, message_dic):
    for each in self.all_clients:
      stored_message = {}
      stored_message['type'] = 'group'
      stored_message['from'] = message_dic['from']
      stored_message['content'] = 'Group-Chat '+ message_dic['content']
      stored_message['timestamp'] = message_dic['timestamp']
      # if the receiver is inactive according to server's table
      if not self.all_clients[each]['status']:
        
        if each in self.offline_messages:
          self.offline_messages[each].append(stored_message)
        else:
          self.offline_messages[each] = [stored_message]
      # if the receiver is active according to server's table
      else:
        group_chat_message_sending = {}
        group_chat_message_sending['type'] = 'group_chat_message_sending'
        group_chat_message_sending['seq'] = self.curr_seq
        curr_seq = self.curr_seq
        self.curr_seq += 1
        group_chat_message_sending['from'] = message_dic['from']
        group_chat_message_sending['timestamp'] = message_dic['timestamp']
        group_chat_message_sending['content'] = message_dic['content']
        self.waiting_ack.add(curr_seq)
        self.socket.sendto(str(group_chat_message_sending).encode(), (self.all_clients[each]['ip'], int(self.all_clients[each]['port'])))
        sleep(0.1)
        # the receiver is indeed active
        if curr_seq not in self.waiting_ack:
          message_from = message_dic['from']
          print(f'>>> [Group Message from {message_from}] delivered to {each}')
        # the receiver is not active: update the table and store the message
        else:
          self.all_clients[each]['status'] = False
          print('>>> [Client table updated.]')
          print('>>> table: ', self.all_clients)
          broadcase_table_thread = Thread(target=self.broadcast_table)
          broadcase_table_thread.start()
          if each in self.offline_messages:
            self.offline_messages[each].append(stored_message)
          else:
            self.offline_messages[each] = [stored_message]


  def broadcast_table(self):
    all_success = False
    while not all_success:
      this_failed = False
      for client in self.all_clients:
        client_name = client
        client = self.all_clients[client]
        if client['status']:
          update_table_message = {}
          update_table_message['type'] = 'update_table'
          update_table_message['seq'] = self.curr_seq
          curr_seq = self.curr_seq
          self.curr_seq += 1
          update_table_message['all_clients'] = self.all_clients
          self.waiting_ack.add(curr_seq)
          self.socket.sendto(str(update_table_message).encode(), (client['ip'], client['port']))
          sleep(0.1)
          if curr_seq in self.waiting_ack:
            self.all_clients[client_name]['status'] = False
            this_failed = True
            break
      all_success = not this_failed