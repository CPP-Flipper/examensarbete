from flask import Flask, request, render_template, session, redirect, url_for
from ai import get_ai_respons
import os

app = Flask(__name__)
app.secret_key = os.urandom(24)


@app.route('/', methods=['GET', 'POST'])
def chat():
    try:
        if 'conv' not in session:
            session['conv'] = []
            session.modified = True

        if request.method == 'POST':
            user_input = request.form.get('text-input')
            if user_input:
                session['conv'].append({"role": "user", "content": user_input})
                ai_respons = get_ai_respons(user_input,session['conv'])
                session['conv'].append({"role": "assistant", "content": ai_respons})
                session.modified = True
                return ai_respons

            return "Ingen inmatning", 400
        else:
            return render_template('main.html', conv=session.get('conv', []))
    except Exception as e:
        print(e)
        return str(e), 400


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8001, debug=True)
