data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

locals {
  web_user_data = <<-EOF
#!/bin/bash
dnf update -y
dnf install -y httpd php php-pgsql

systemctl enable httpd
systemctl start httpd

echo "OK" > /var/www/html/health.html

cat >/var/www/html/index.php <<'PHP'
<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);

$host = "${aws_rds_cluster.aurora_pg.endpoint}";
$port = "5432";
$dbname = "appdb";
$user = "postgres";
$password = "RosiCS1_DB!";
$hostname = gethostname();

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname;";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    $pdo->exec("
        CREATE TABLE IF NOT EXISTS users (
            id SERIAL PRIMARY KEY,
            username VARCHAR(100) NOT NULL,
            email VARCHAR(150),
            message TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ");

    $pdo->exec("
        CREATE TABLE IF NOT EXISTS visits (
            id SERIAL PRIMARY KEY,
            server_name VARCHAR(100) NOT NULL,
            visited_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ");

    $stmtVisit = $pdo->prepare("INSERT INTO visits (server_name) VALUES (:server_name)");
    $stmtVisit->execute(['server_name' => $hostname]);

    if ($_SERVER["REQUEST_METHOD"] === "POST") {
        $username = trim($_POST["username"] ?? "");
        $email    = trim($_POST["email"] ?? "");
        $message  = trim($_POST["message"] ?? "");

        if ($username !== "") {
            $stmt = $pdo->prepare("
                INSERT INTO users (username, email, message)
                VALUES (:username, :email, :message)
            ");
            $stmt->execute([
                'username' => $username,
                'email'    => $email,
                'message'  => $message
            ]);
        }
    }

    $users = $pdo->query("
        SELECT id, username, email, message, created_at
        FROM users
        ORDER BY id DESC
        LIMIT 10
    ")->fetchAll(PDO::FETCH_ASSOC);

    $visits = $pdo->query("
        SELECT id, server_name, visited_at
        FROM visits
        ORDER BY id DESC
        LIMIT 10
    ")->fetchAll(PDO::FETCH_ASSOC);

    $dbStatus = "Connected";
} catch (Exception $e) {
    $dbStatus = "Failed: " . $e->getMessage();
    $users = [];
    $visits = [];
}
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Case Study MVP</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f5f7fb;
            margin: 0;
            padding: 0;
        }
        .container {
            max-width: 1000px;
            margin: 40px auto;
            padding: 20px;
        }
        .card {
            background: white;
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
        }
        h1, h2 {
            margin-top: 0;
        }
        input, textarea {
            width: 100%;
            padding: 10px;
            margin: 8px 0 16px 0;
            border: 1px solid #ccc;
            border-radius: 8px;
            box-sizing: border-box;
        }
        button {
            background: #2563eb;
            color: white;
            border: none;
            padding: 10px 16px;
            border-radius: 8px;
            cursor: pointer;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th, td {
            padding: 10px;
            border-bottom: 1px solid #ddd;
            text-align: left;
            vertical-align: top;
        }
        .status {
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="card">
            <h1>Infrastructure Demo Portal</h1>
            <p><strong>Served by:</strong> <?php echo htmlspecialchars($hostname); ?></p>
            <p><strong>Database status:</strong> <span class="status"><?php echo htmlspecialchars($dbStatus); ?></span></p>
        </div>

        <div class="card">
            <h2>Add User</h2>
            <form method="post">
                <label>Username</label>
                <input type="text" name="username" required>

                <label>Email</label>
                <input type="email" name="email">

                <label>Message</label>
                <textarea name="message" rows="4"></textarea>

                <button type="submit">Save</button>
            </form>
        </div>

        <div class="card">
            <h2>Recent Users</h2>
            <table>
                <tr>
                    <th>ID</th>
                    <th>Username</th>
                    <th>Email</th>
                    <th>Message</th>
                    <th>Created At</th>
                </tr>
                <?php foreach ($users as $row): ?>
                <tr>
                    <td><?php echo htmlspecialchars($row['id']); ?></td>
                    <td><?php echo htmlspecialchars($row['username']); ?></td>
                    <td><?php echo htmlspecialchars($row['email']); ?></td>
                    <td><?php echo htmlspecialchars($row['message']); ?></td>
                    <td><?php echo htmlspecialchars($row['created_at']); ?></td>
                </tr>
                <?php endforeach; ?>
            </table>
        </div>

        <div class="card">
            <h2>Recent Visits</h2>
            <table>
                <tr>
                    <th>ID</th>
                    <th>Server Name</th>
                    <th>Visited At</th>
                </tr>
                <?php foreach ($visits as $row): ?>
                <tr>
                    <td><?php echo htmlspecialchars($row['id']); ?></td>
                    <td><?php echo htmlspecialchars($row['server_name']); ?></td>
                    <td><?php echo htmlspecialchars($row['visited_at']); ?></td>
                </tr>
                <?php endforeach; ?>
            </table>
        </div>
    </div>
</body>
</html>
PHP
EOF
}

resource "aws_instance" "web1" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.web_a.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  associate_public_ip_address = false
  user_data_replace_on_change = true
  user_data                   = local.web_user_data

  tags = {
    Name    = "${var.project}-web1"
    Project = var.project
    Role    = "web"
  }
}

resource "aws_instance" "web2" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.web_b.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  associate_public_ip_address = false
  user_data_replace_on_change = true
  user_data                   = local.web_user_data

  tags = {
    Name    = "${var.project}-web2"
    Project = var.project
    Role    = "web"
  }
}