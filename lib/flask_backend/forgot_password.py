from flask import Blueprint, request, jsonify
from flask_mail import Message
from werkzeug.security import generate_password_hash
from datetime import datetime, timedelta
import random
import string
import pymysql

from extensions import mail

forgot_password_bp = Blueprint('forgot_password', __name__)

def get_db_connection():
    return pymysql.connect(
        host='localhost',
        user='root',
        password='',
        database='bbb',
        port=3306
    )


@forgot_password_bp.route('/forgot_password', methods=['POST'])
def forgot_password():
    data = request.get_json()
    email = data.get('email')

    if not email:
        return jsonify({'status': 'error', 'message': 'Email is required'}), 400

    conn = get_db_connection()
    cursor = conn.cursor(pymysql.cursors.DictCursor)

    try:
        # Check users table
        cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
        user = cursor.fetchone()

        if user:
            return handle_temp_password(cursor, conn, email, user, table="users")

        # Check sellers table
        cursor.execute("SELECT * FROM sellers WHERE email = %s", (email,))
        seller = cursor.fetchone()

        if seller:
            return handle_temp_password(cursor, conn, email, seller, table="sellers")

        return jsonify({'status': 'error', 'message': 'This email is not registered.'}), 404

    except Exception as e:
        print(f"❌ Error: {e}")
        return jsonify({'status': 'error', 'message': 'Server error'}), 500
    finally:
        cursor.close()
        conn.close()


def handle_temp_password(cursor, conn, email, account, table):
    temp_password = ''.join(random.choices(string.ascii_letters + string.digits, k=8))
    hashed_password = generate_password_hash(temp_password, method='pbkdf2:sha256')
    expiry_time = datetime.now() + timedelta(minutes=5)

    cursor.execute(f"""
        UPDATE {table}
        SET password = %s, password_expiry = %s
        WHERE email = %s
    """, (hashed_password, expiry_time, email))
    conn.commit()

    full_name = f"{account.get('first_name', '')} {account.get('last_name', '')}".strip()
    msg = Message('Password Reset Request',
                  sender='sampleecommerce05@gmail.com',
                  recipients=[email])
    msg.body = (
        f"Hello {full_name or 'User'},\n\n"
        f"Your temporary password is: {temp_password}\n"
        f"Please log in and change your password immediately.\n"
        f"This password will expire in 5 minutes.\n\n"
        f"Best regards,\nSupport Team"
    )
    mail.send(msg)

    return jsonify({'status': 'success', 'message': 'Temporary password sent to your email.'}), 200
