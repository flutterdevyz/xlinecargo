const API_URL = 'http://localhost:8080';

const loginForm = document.getElementById('login-form');
const loginContainer = document.getElementById('login-container');
const dashboardContainer = document.getElementById('dashboard-container');
const logoutBtn = document.getElementById('logout-btn');
const refreshBtn = document.getElementById('refresh-btn');
const ordersTableBody = document.querySelector('#orders-table tbody');
const loginError = document.getElementById('login-error');

// Check token on load
const token = localStorage.getItem('token');
if (token) {
    showDashboard();
}

loginForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const phone = document.getElementById('phone').value;
    const password = document.getElementById('password').value;

    try {
        const response = await fetch(`${API_URL}/auth/admin/login`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            // Admin default userda email 'admin' qilib saqlangan
            body: JSON.stringify({ email: phone, password: password })
        });

        if (response.ok) {
            const data = await response.json();
            if (data.token) {
                localStorage.setItem('token', data.token);
                showDashboard();
            } else {
                showError('Token not found in response');
            }
        } else {
            showError('Invalid credentials');
        }
    } catch (error) {
        showError('Network error');
    }
});

logoutBtn.addEventListener('click', () => {
    localStorage.removeItem('token');
    loginContainer.style.display = 'block';
    dashboardContainer.style.display = 'none';
    document.body.style.alignItems = 'center';
});

refreshBtn.addEventListener('click', loadOrders);

function showDashboard() {
    loginContainer.style.display = 'none';
    dashboardContainer.style.display = 'flex';
    document.body.style.alignItems = 'flex-start'; // Allow dashboard to expand
    loadOrders();
}

function showError(msg) {
    loginError.textContent = msg;
    loginError.style.display = 'block';
}

async function loadOrders() {
    const token = localStorage.getItem('token');
    if (!token) return;

    try {
        const response = await fetch(`${API_URL}/admin/order/all`, {
            headers: { 'Authorization': `Bearer ${token}` }
        });

        if (response.ok) {
            const orders = await response.json();
            renderOrders(orders);
        } else {
            console.error('Failed to fetch orders');
            if (response.status === 401) {
                logoutBtn.click(); // Token expired
            }
        }
    } catch (error) {
        console.error('Error fetching orders:', error);
    }
}

function renderOrders(orders) {
    ordersTableBody.innerHTML = '';
    orders.forEach(order => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td>${order.id || 'N/A'}</td>
            <td>${order.user_id || 'N/A'}</td>
            <td>${order.status || 'N/A'}</td>
            <td>${order.created_at || 'N/A'}</td>
        `;
        ordersTableBody.appendChild(row);
    });
}
