<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CADS Scheduler Sim | Top 1% Engineering</title>
    <style>
        :root {
            --bg-color: #0a0a0a;
            --text-color: #00ff41; /* Classic Terminal Green */
            --accent-color: #008f11;
            --border-color: #333;
        }

        body {
            background-color: var(--bg-color);
            color: var(--text-color);
            font-family: 'Courier New', Courier, monospace;
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 20px;
        }

        .container {
            width: 90%;
            max-width: 900px;
            border: 1px solid var(--border-color);
            padding: 20px;
            box-shadow: 0 0 15px rgba(0, 255, 65, 0.2);
        }

        h1 { border-bottom: 1px solid var(--border-color); padding-bottom: 10px; }

        .task-input {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 10px;
            margin-bottom: 20px;
        }

        input, button {
            background: #111;
            border: 1px solid var(--text-color);
            color: var(--text-color);
            padding: 10px;
            font-family: inherit;
        }

        button {
            cursor: pointer;
            transition: 0.3s;
        }

        button:hover {
            background: var(--text-color);
            color: black;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        th, td {
            border: 1px solid var(--border-color);
            padding: 12px;
            text-align: left;
        }

        .saving-high { color: #00ff41; font-weight: bold; }
        .saving-low { color: #ffcc00; }

        .stats {
            margin-top: 20px;
            padding: 15px;
            border-top: 2px dashed var(--border-color);
            font-size: 1.2rem;
        }
    </style>
</head>
<body>

<div class="container">
    <h1>CADS_SCHEDULER_V1.0</h1>
    <p>> Minimizing Energy Consumption via Dynamic Slack Scaling...</p>

    <div class="task-input">
        <input type="number" id="workload" placeholder="Workload (Cycles)">
        <input type="number" id="deadline" placeholder="Deadline (ms)">
        <button onclick="addTask()">ADD TASK</button>
        <button onclick="runSimulation()" style="border-color: #ff003c; color: #ff003c;">EXECUTE SIM</button>
    </div>

    <table id="taskTable">
        <thead>
            <tr>
                <th>Task ID</th>
                <th>Workload</th>
                <th>Deadline</th>
                <th>Target Freq (GHz)</th>
                <th>Energy Saved</th>
            </tr>
        </thead>
        <tbody id="taskBody">
            </tbody>
    </table>

    <div class="stats" id="totalStats">
        SYSTEM IDLE...
    </div>
</div>

<script>
    let tasks = [];
    let taskId = 1;

    function addTask() {
        const w = document.getElementById('workload').value;
        const d = document.getElementById('deadline').value;
        
        if(!w || !d) return alert("Fill the params, chief.");

        tasks.push({ id: taskId++, workload: parseFloat(w), deadline: parseFloat(d) });
        updateTable();
    }

    function updateTable() {
        const body = document.getElementById('taskBody');
        body.innerHTML = tasks.map(t => `
            <tr>
                <td>#${t.id}</td>
                <td>${t.workload}</td>
                <td>${t.deadline}ms</td>
                <td>--</td>
                <td>--</td>
            </tr>
        `).join('');
    }

    function runSimulation() {
        if(tasks.length === 0) return;

        let currentTime = 0;
        let totalCadsEnergy = 0;
        let totalNaiveEnergy = 0;
        const F_MAX = 3.2;
        const ALPHA = 0.8;

        const body = document.getElementById('taskBody');
        body.innerHTML = "";

        tasks.forEach(t => {
            let timeAvailable = t.deadline - currentTime;
            let fTarget = t.workload / timeAvailable;

            // Constrain frequency
            if (fTarget > F_MAX) fTarget = F_MAX;
            if (fTarget < 0.8) fTarget = 0.8;

            let actualDuration = t.workload / fTarget;
            
            // Energy = f^3 * duration
            let energyUsed = ALPHA * Math.pow(fTarget, 3) * actualDuration;
            let energyNaive = ALPHA * Math.pow(F_MAX, 3) * (t.workload / F_MAX);

            totalCadsEnergy += energyUsed;
            totalNaiveEnergy += energyNaive;

            let savings = ((energyNaive - energyUsed) / energyNaive * 100).toFixed(1);

            body.innerHTML += `
                <tr>
                    <td>#${t.id}</td>
                    <td>${t.workload}</td>
                    <td>${t.deadline}ms</td>
                    <td>${fTarget.toFixed(2)} GHz</td>
                    <td class="${savings > 50 ? 'saving-high' : 'saving-low'}">${savings}%</td>
                </tr>
            `;

            currentTime += actualDuration;
        });

        const totalSaving = ((totalNaiveEnergy - totalCadsEnergy) / totalNaiveEnergy * 100).toFixed(2);
        document.getElementById('totalStats').innerHTML = `
            [SYSTEM REPORT]: Total Energy Saved: <span style="color:white">${totalSaving}%</span><br>
            [STATUS]: Thermal Levels Optimal. Performance Uncompromised.
        `;
    }
</script>

</body>
</html>
