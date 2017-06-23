# Copyright (c) 2017 Aleksandr Borisenko
# Licensed under the Apache License, Version 2.0
from bottle import run, template, request, redirect, Bottle, static_file
from beaker.middleware import SessionMiddleware
from configparser import ConfigParser
import webdav.client as wc
from webdav.exceptions import RemoteParentNotFound
import tempfile
import base64
import uuid
import time
import datetime
import json
import os
# import pprint

config = ConfigParser()
config.read('config.ini')

SYNC_DIR = config['SERVER']['SYNC_DIR']
LINKS_DIR = '/links'
NOTES_DIR = '/notes'

DEFAULT_HOST = config['SERVER']['DEFAULT_HOST']
DEFAULT_LOGIN = config['SERVER']['DEFAULT_LOGIN']
DEFAULT_PASSWORD = config['SERVER']['DEFAULT_PASSWORD']
DEFAULT_ROOT = config['SERVER']['DEFAULT_ROOT']

session_opts = {
    'session.type': 'file',
    'session.data_dir': './session/',
    'session.auto': True,
}
app = Bottle()


@app.route('/static/<path:path>', name='static')
def uploader_static(path):
    return static_file(path, root='static')


@app.route('/save', method='POST')
def uploader_save():
    session = request.environ['beaker.session']
    errors = []
    messages = []
    # pp = pprint.PrettyPrinter(indent=4)
    # pp.pprint(request.forms.__dict__)
    data = {
        'hostname': request.forms['hostname'],
        'login': request.forms['login'],
        'password': request.forms['password'],
        'root': request.forms['root'],
        'url': request.forms['url'].strip(),
        'title': request.forms['title'].strip(),
        'note': request.forms['note'].strip(),
        'tags': request.forms['tags'].strip(), }
    upload = request.files.upload
    webdav_options = {
        'webdav_hostname': data['hostname'],
        'webdav_login': data['login'],
        'webdav_password': data['password'],
        'webdav_root': data['root'], }
    client = wc.Client(webdav_options)
    try:
        if data['url'] or data['note']:
            link_id = ""
            if (data['url']):
                link_id = generate_uuid_id()
                link_json = build_link_json(
                    link_id, data['url'], data['title'], data['tags'])
                upload_link(client, link_id, link_json)
                messages.append("Uploaded Link: {0}".format(link_id))
            if (data['note']):
                note_id = generate_uuid_id()
                note_json = build_note_json(
                    note_id, link_id, data['note'], data['tags'])
                upload_note(client, note_id, note_json)
                messages.append("Uploaded Note: {0}".format(note_id))
        elif upload:
            name, ext = os.path.splitext(upload.filename)
            if (ext == '.txt'):
                    uploaded = upload_file(client, upload)
                    messages.append("Uploaded: {0}".format(uploaded))
            else:
                errors.append(
                    "The file must be a text file with .txt extension")
        else:
            errors.append("URL, Note or File must be specified")
    except RemoteParentNotFound:
        errors.append("RemoteParentNotFound exception: "
                        "probably credentials are invalid")

    if len(errors) <= 0:
        data['url'] = ''
        data['title'] = ''
        data['note'] = ''
        data['tags'] = ''

    session['errors'] = errors
    session['messages'] = messages
    session['data'] = data
    redirect('/')


def generate_uuid_id():
    return base64.urlsafe_b64encode(
        uuid.uuid4().bytes).decode('UTF-8').rstrip('=')


def build_link_json(link_id, url, title, tags):
    now = datetime.datetime.now()
    created = int(time.mktime(now.timetuple()) * 1000 + now.microsecond / 1000)
    tags_array = [x.strip() for x in tags.split(',') if x]
    tags_json = list({'name': tag} for tag in tags_array)
    link_json = {
        "version": 1, "link": {
            "id": link_id, "created": created, "updated": created,
            "link": url, "name": title, "disabled": False, "tags": tags_json}}
    return json.dumps(link_json, ensure_ascii=False).replace('/', '\\/')


def build_note_json(note_id, link_id, note, tags):
    now = datetime.datetime.now()
    created = int(time.mktime(now.timetuple()) * 1000 + now.microsecond / 1000)
    tags_array = [x.strip() for x in tags.split(',') if x]
    tags_json = list({'name': tag} for tag in tags_array)
    note_json = {
        "version": 1, "note": {
            "id": note_id, "created": created, "updated": created,
            "note": note, "link_id": link_id, "tags": tags_json}}
    return json.dumps(note_json, ensure_ascii=False).replace('/', '\\/')


def upload_link(client, link_id, link_json):
    upload_data(client, link_id, link_json, LINKS_DIR)


def upload_note(client, note_id, note_json):
    upload_data(client, note_id, note_json, NOTES_DIR)


def upload_data(client, data_id, data_json, data_dir):
    tmp = tempfile.NamedTemporaryFile(delete=True)
    try:
        tmp.write(data_json.encode('UTF-8'))
        tmp.flush()
        client.upload_sync(
            remote_path=SYNC_DIR + data_dir + "/" + data_id + ".json",
            local_path=tmp.name)
    finally:
        tmp.close()


def upload_file(client, upload):
    tmp = tempfile.NamedTemporaryFile(delete=True)
    count = 0
    try:
        upload.save(tmp)
        tmp.seek(0)
        bookmark_url = ''
        bookmark_title = ''
        bookmark_note = ''
        bookmark_tags = ''
        for raw in tmp.readlines():
            line = raw.decode(encoding='UTF-8').strip()
            if not line:
                if bookmark_url:
                    link_id = generate_uuid_id()
                    link_json = build_link_json(
                        link_id, bookmark_url, bookmark_title, bookmark_tags)
                    upload_link(client, link_id, link_json)
                    count += 1
                    print("{0}. LINK: {1}".format(count, bookmark_url))
                bookmark_note = bookmark_note.strip()
                if bookmark_note:
                    note_id = generate_uuid_id()
                    note_json = build_note_json(
                        note_id, bookmark_note, bookmark_tags)
                    upload_note(client, note_id, note_json)
                    count += 1
                    print("{0}. NOTE: {1}".format(count, bookmark_note))
                bookmark_url = ''
                bookmark_title = ''
                bookmark_note = ''
                bookmark_tags = ''
            else:
                key, value = line.split(':', maxsplit=1)
                if key == 'url':
                    bookmark_url = value.strip()
                elif key == 'title':
                    bookmark_title = value.strip()
                elif key == 'note':
                    bookmark_note += value + "\r\n"
                elif key == 'tags':
                    bookmark_tags = value.strip()
    finally:
        tmp.close()
    return count


@app.route('/')
def uploader_index():
    session = request.environ['beaker.session']
    errors = session.get('errors', [])
    messages = session.get('messages', [])
    data_default = {
        'hostname': DEFAULT_HOST,
        'login': DEFAULT_LOGIN,
        'password': DEFAULT_PASSWORD,
        'root': DEFAULT_ROOT,
        'url': '',
        'title': '',
        'note': '',
        'tags': '', }
    data = session.get('data', data_default)
    session.delete()
    output = template(
        'templates/uploader_index',
        errors=errors,
        messages=messages,
        directory=SYNC_DIR,
        data=data,
    )
    return output

app = application = SessionMiddleware(app, session_opts)
if __name__ == "__main__":
    run(app=app, host=config['APP']['HOST'],
        port=config['APP']['PORT'],
        debug=config['APP']['DEBUG'] == "1",
        reloader=config['APP']['RELOADER'] == "1")
