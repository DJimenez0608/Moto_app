import bodyParser from "body-parser"
import express from "express"
import pg from "pg"
import bcrypt from "bcrypt"
import dotenv from "dotenv"
import jwt from "jsonwebtoken"

const app = express();
const port = 3000; 
const saltRounds = parseInt(process.env.SALT_ROUNDS, 10);

dotenv.config();

const db = new pg.Client({
    user: process.env.PG_USER,
    host: process.env.PG_HOST,
    database: process.env.PG_DATABASE,
    password: process.env.PG_PASSWORD,
    port: process.env.PG_PORT,
  });

db.connect();

app.use(express.json());
app.use(bodyParser.urlencoded({ extended: true }));




//OBTENER TODOS LOS USUARIOS
app.get("/users", (req, res) => {
    
})
//OBTENER INFO DE USUARIO
app.get("/users/:id", async (req, res) => {
    //Ya se hace en el login

})
//OBTENER INFO DE LAS MOTOS DEL USUARIO
app.get("/users/:id/motorcycles", async (req, res) => {
    const userId = req.params.id
    //Verificar que haya exista el usuario con ese Id
    const userexist = await db.query(
        "SELECT * FROM users WHERE users.id = $1",
        [userId]
    )
    
    if (userexist.rows.length < 1) {
        return res.status(400).send("El usuario noe existe")
    }

    //Buscar las motos que esten asociadas al usuario con id userId
    const userMotorcycles = await db.query(
        "SELECT * FROM motorcycles where motorcycles.user_id = $1;",
        [userId]
    )
    const userMotorcyclesRows = userMotorcycles.rows 

    if (userMotorcyclesRows.length< 1) {
        return null
    }

    res.status(200).json({userMotorcyclesRows})


})
//OBTENER LOS VIAJES DEL USUARIO
app.get("/users/:id/travels", (req, res) => {
    
})
//OBTENER LAS OBSERVACIONES DE UNA MOTO
app.get("/motorcycle/:id/observations", (req, res) => {
    
})
//OBTENER INFO DE LOS REGISTROS DE MANTENIMIENTO
app.get("/motorcycle/:id/maintenance", async (req, res) => {
    const motorcycleId = req.params.id;

    try {
        const motorcycle = await db.query(
            "SELECT id FROM motorcycles WHERE motorcycles.id = $1;",
            [motorcycleId]
        );

        if (motorcycle.rows.length < 1) {
            return res.status(404).send("La motocicleta no existe");
        }

        const maintenance = await db.query(
            "SELECT * FROM maintenance WHERE maintenance.motorcycle_id = $1 ORDER BY date DESC;",
            [motorcycleId]
        );

        const maintenanceRows = maintenance.rows;

        return res.status(200).json({ maintenanceRows });
    } catch (error) {
        console.log(error);
        res.status(500).send("Error al obtener registros de mantenimiento");
    }
})


//INICIAR SESION
app.post("/users/login", async (req, res) => {
    const username = req.body.username
    const password = req.body.password

    try {
        if (!username  || !password)
            {
                return res.status(400).send("Falta iunformacion ")
            } 
        
        const usersDB = await db.query(
            "SELECT * FROM users WHERE users.email = $1 OR users.username = $1   ",
            [username]
        )
        const userBDrows = usersDB.rows[0]

        if (!userBDrows) {
            return res.status(401).send("Usuario o contraseña incorrectas");
        }
        

        const DBPassword = userBDrows.password
        bcrypt.compare(password, DBPassword, async (error, result) => {
            if (error) {
                return res.status(400).send(error)
            } else {
                if (result) {
                    const jwtSecret = process.env.JWT_SECRET || "moto_app_secret_key_change_in_production"
                    const token = jwt.sign(
                        { 
                            userId: userBDrows.id,
                            username: userBDrows.username 
                        },
                        jwtSecret,
                        { expiresIn: '30d' }
                    )
                    res.status(200).json({
                        success: true,
                        message: "usuario logueado",
                        token: token,
                        username: userBDrows.username,
                        fullName: userBDrows.full_name,
                        email: userBDrows.email,
                        phoneNumber: userBDrows.phone_number,
                        id : userBDrows.id,
                    })
                } else {
                    res.status(401).send("Usuario o contraseña incorrecta")
                }
            }
        })
    } catch (error) {
        console.log(error);
        res.status(500).send("Error al obtener registro de usuario")
    }
})

//CERRAR SESION
app.post("/users/logout", (req, res) => {
    try {
        res.status(200).json({
            success: true,
            message: "Sesión cerrada exitosamente"
        })
    } catch (error) {
        console.log(error);
        res.status(500).send("Error al cerrar sesión")
    }
})

//REGISTRAR USUARIO
app.post("/users", async (req, res) => {

    try {

        const fullName = req.body.fullname
        const email = req.body.email
        const username = req.body.username
        const password = req.body.password
        const phoneNumber = req.body.phoneNumber

        if (!fullName || !email || !password || !phoneNumber || !username) {
            
            return res.status(400).send("Falta informacion para hacer el registro del usuario")
        }

        const userExist = await db.query(
            "SELECT * FROM users WHERE users.email = $1 OR users.username = $1 ",
            [username]
        )
        const usersRows = userExist.rows

        if (usersRows.length > 0) {
            return res.status(409).send("Usuario ya existente")
        }

        bcrypt.hash(password, saltRounds, async (error, hash) => {
            if (error) {
                return res.status(400).send(error)
            } else {
                await db.query(
                    "INSERT INTO users (full_name, email, phone_number, username, password) VALUES ($1, $2, $3, $4, $5);",
                    [fullName, email, phoneNumber, username, hash ]
                )
                res.status(201).send("Usuario reguistrado con exito")
            }

        }
        )

        

        
    } catch (error) {
        console.log(error);
        res.status(500).json({
            succes: false,
            message: "Error al obtener datos de usuario"
        })
    }
    
}
)
//REGISTRAR MANTENIMIENTO
app.post("/motorcycle/:id/maintenance", (req, res) => {
    
})
//REGISTRAR OBSERVACION
app.post("/motorcycle/:id/observations", (req, res) => {
    
})
//REGISTRAR MOTO DE USUARIO
app.post("/users/:id/motorcycles", (req, res) => {

    const userId = req.params.id
    
}) 
//REGISTRAR VIAJE DE USUARIO 
app.post("/users/:id/travels", (req, res) => {
    
})


app.listen(port, () => {
    console.log("server listening by port 3000")
})