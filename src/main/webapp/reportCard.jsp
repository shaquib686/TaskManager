<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<link rel="stylesheet" href="reportCard.css">

<div class="report-card">
  <!-- Only the relevant part shown -->
  <div class="report-card-header">
    <div class="report-card-toggle-row">
      <div class="toggle-group">
        <button class="report-tab active">Pending</button>
        <button class="report-tab">Completed</button>
        <button class="report-tab">Expired</button>
      </div>
    </div>
    <div class="report-card-dropdown-row">
      <select id="report-type" class="report-type-dropdown">
        <option value="daily">Daily</option>
        <option value="weekly">Weekly</option>
        <option value="monthly">Monthly</option>
      </select>
      <div class="custom-dropdown" id="custom-dropdown">
        <button type="button" id="custom-dropdown-btn" class="custom-dropdown-btn">2025-7</button>
        <div class="custom-dropdown-menu" id="custom-dropdown-menu"></div>
      </div>
    </div>
  </div>
  <div class="report-card-chart">
    <canvas id="reportChart"></canvas>
  </div>
  <div class="report-card-summary">
    <span class="easy">Easy 31</span>
    <span class="medium">Med. 75</span>
    <span class="hard">Hard 27</span>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
  document.addEventListener('DOMContentLoaded', function () {
  // Toggle logic
  document.querySelectorAll('.report-tab').forEach(tab => {
    tab.addEventListener('click', function() {
      document.querySelectorAll('.report-tab').forEach(t => t.classList.remove('active'));
      this.classList.add('active');
      // Optionally: update chart/data here based on toggle
    });
  });

  // Dropdown logic
  const typeSelect = document.getElementById('report-type');
  const customDropdown = document.getElementById('custom-dropdown');
  const customDropdownBtn = document.getElementById('custom-dropdown-btn');
  const customDropdownMenu = document.getElementById('custom-dropdown-menu');

  const YEAR_RANGE = 10;
  const now = new Date();
  let selectedYear = now.getFullYear();
  let selectedMonth = now.getMonth() + 1;

  function pad2(n) {
    return n < 10 ? '0' + n : n;
  }

  function updateDropdownBtn() {
    if (typeSelect.value === 'monthly') {
      customDropdownBtn.textContent = selectedYear;
    } else {
      customDropdownBtn.textContent = selectedYear + " - " + selectedMonth;
    }
  }

  function renderCustomDropdown() {
    customDropdownMenu.innerHTML = '';
    const startYear = now.getFullYear() - YEAR_RANGE + 1;
    const endYear = now.getFullYear();

    if (typeSelect.value === 'monthly') {
      // Only year column, ascending order
      const yearsCol = document.createElement('div');
      yearsCol.className = 'custom-dropdown-col';
      for (let y = startYear; y <= endYear; y++) {
        const btn = document.createElement('button');
        btn.className = 'custom-dropdown-item' + (y === selectedYear ? ' selected' : '');
        btn.textContent = y;
        btn.onclick = (e) => {
          e.stopPropagation();
          selectedYear = y;
          updateDropdownBtn();
          customDropdown.classList.remove('open');
          renderCustomDropdown();
        };
        yearsCol.appendChild(btn);
      }
      customDropdownMenu.appendChild(yearsCol);
    } else {
      // Year and month columns, years ascending
      const yearsCol = document.createElement('div');
      yearsCol.className = 'custom-dropdown-col';
      for (let y = startYear; y <= endYear; y++) {
        const btn = document.createElement('button');
        btn.className = 'custom-dropdown-item' + (y === selectedYear ? ' selected' : '');
        btn.textContent = y;
        btn.onclick = (e) => {
          e.stopPropagation();
          selectedYear = y;
          if (selectedYear === now.getFullYear() && selectedMonth > now.getMonth() + 1) {
            selectedMonth = now.getMonth() + 1;
          }
          updateDropdownBtn();
          renderCustomDropdown();
          setTimeout(() => {
            btn.scrollIntoView({ block: 'nearest' });
          }, 0);
        };
        yearsCol.appendChild(btn);
      }
      const monthsCol = document.createElement('div');
      monthsCol.className = 'custom-dropdown-col';
      let maxMonth = (selectedYear === now.getFullYear()) ? (now.getMonth() + 1) : 12;
      for (let m = 1; m <= maxMonth; m++) {
        const btn = document.createElement('button');
        btn.className = 'custom-dropdown-item' + (m === selectedMonth ? ' selected' : '');
        btn.textContent = pad2(m);
        btn.onclick = (e) => {
          e.stopPropagation();
          selectedMonth = m;
          updateDropdownBtn();
          customDropdown.classList.remove('open');
          renderCustomDropdown();
        };
        monthsCol.appendChild(btn);
      }
      customDropdownMenu.appendChild(yearsCol);
      customDropdownMenu.appendChild(monthsCol);

      setTimeout(() => {
        const selectedYearBtn = yearsCol.querySelector('.selected');
        if (selectedYearBtn) selectedYearBtn.scrollIntoView({ block: 'nearest' });
      }, 0);
    }
    updateDropdownBtn();
  }

  customDropdownBtn.addEventListener('click', function (e) {
    e.stopPropagation();
    customDropdown.classList.toggle('open');
    renderCustomDropdown();
  });

  document.addEventListener('click', function () {
    customDropdown.classList.remove('open');
  });

  typeSelect.addEventListener('change', function () {
    selectedYear = now.getFullYear();
    selectedMonth = now.getMonth() + 1;
    renderCustomDropdown();
  });

  renderCustomDropdown();


  // Chart.js initialization
  const ctx = document.getElementById('reportChart');
  if (ctx) {
    new Chart(ctx, {
      type: 'bar',
      data: {
        labels: ['07.01', '07.05', '07.10', '07.15', '07.20', '07.25', '07.31'],
        datasets: [
          {
            label: 'Easy',
            backgroundColor: '#00d8a7',
            data: [2, 5, 8, 3, 6, 7, 0]
          },
          {
            label: 'Med.',
            backgroundColor: '#ffc300',
            data: [4, 8, 12, 6, 10, 15, 20]
          },
          {
            label: 'Hard',
            backgroundColor: '#ff4d4f',
            data: [1, 2, 3, 1, 2, 3, 2]
          }
        ]
      },
      options: {
        responsive: true,
        plugins: {
          legend: { display: false }
        },
        scales: {
          x: {
            grid: { color: '#222' },
            ticks: { color: '#aaa' }
          },
          y: {
            grid: { color: '#222' },
            ticks: { color: '#aaa' }
          }
        }
      }
    });
  }
});
</script>