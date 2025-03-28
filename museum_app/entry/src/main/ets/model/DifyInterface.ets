import { http } from "@kit.NetworkKit"

export enum  ResponseMode{
  STREAMING='streaming',
  BLOCKING='blocking'
}
export enum  ChatEvent{
  MESSAGE='message',
  MESSAGE_END='message_end',
  MESSAGE_FILE='message_file',
  TTS_MESSAGE='tts_message',
  TTS_MESSAGE_END='tts_message_end',
  PING='ping',
  ERROR='error',
  NODE_FINISHED='node_finished',
  NODE_STARTED='node_started'
}
export interface SuggestedResponse{
  result:string,
  data:string[]
}
export interface ChatInputs{
  visit_item:string;
}
export interface ChatBody{
  query: string;
  inputs: ChatInputs;
  response_mode: ResponseMode;
  user: string; //AAID
  conversation_id?: string;
  auto_generate_name?: boolean;
}
export interface BaseChatFlow{event:string}
export interface NodeData{
  id: string;
  node_id: string;
  node_type: string;
  title: string;
  index: number;
  predecessor_node_id: null | string;
  created_at: number;
  status?: string;
}
export interface NodeFlow extends BaseChatFlow{
  event:'node',
  task_id: string;
  workflow_run_id: string;
  data: NodeData;
  conversation_id?: string;
  created_at?: number;
  message_id?: string;
}
export interface MessageChatFlow extends BaseChatFlow{
  event:'message'|'message_replace'
  task_id:string,
  message_id:string,
  conversation_id:string,
  answer:string,
  created_at:number,
}
export interface FileChatFlow extends BaseChatFlow{
  event:'message_file',
  id:string,
  type:string,
  belongs_to:string,
  url:string,
  conversation_id:string,
}
export interface MessageEndFlow extends BaseChatFlow{
  event:'message_end',
  task_id:string,
  message_id:string,
  conversation_id:string,
  metadata:object,
}
export interface TTSChatFlow extends BaseChatFlow{
  event:'tts_message'|'tts_message_end',
  task_id:string,
  message_id:string,
  audio:string,
  created_at:number,
}
export interface PingFlow extends BaseChatFlow{event:'ping'}
export interface ErrorFlow extends BaseChatFlow{
  event:'error',
  task_id:string,
  message_id:string,
  status:http.ResponseCode,
  code:string,
  message:string
}

export interface Parameters {
  annotation_reply?: AnnotationReply;
  file_upload?: FileUpload;
  opening_statement?: string;
  retriever_resource?: RetrieverResource;
  speech_to_text?: SpeechToText;
  suggested_questions?: string[];
  suggested_questions_after_answer?: SuggestedQuestionsAfterAnswer;
  system_parameters?: SystemParameters;
  user_input_form?: UserInputForm[];
}
export interface OpeningInfo extends Parameters{
  opening_statement:string,
  suggested_questions: string[]
}

export interface AnnotationReply {
  enabled: boolean;
}

export interface FileUpload {
  image: Image;
}

export interface Image {
  enabled: boolean;
  number_limits: number;
  transfer_methods: string[];
}

export interface RetrieverResource {
  enabled: boolean;
}

export interface SpeechToText {
  enabled: boolean;
}

export interface SuggestedQuestionsAfterAnswer {
  enabled: boolean;
}

export interface SystemParameters {
  audio_file_size_limit: number;
  file_size_limit: number;
  image_file_size_limit: number;
  video_file_size_limit: number;
}

export interface UserInputForm {
  "text-input"?: TextInput;
}

export interface TextInput {
  default: string;
  label: string;
  max_length: number;
  required: boolean;
  variable: string;
}