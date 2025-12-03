import bodyParser from "body-parser"
import express from "express"
import pg from "pg"
import bcrypt from "bcrypt"
import dotenv from "dotenv"
import jwt from "jsonwebtoken"
import path from "path"
import { fileURLToPath } from "url"

// Obtener el directorio actual (para ES modules)
const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

// CARGAR VARIABLES DE ENTORNO PRIMERO - Especificar ruta explícita
// El .env está en el directorio padre (moto_app/.env)
const envPath = path.join(__dirname, '..', '.env');
const result = dotenv.config({ path: envPath });

if (result.error) {
  console.warn('Advertencia: No se pudo cargar el archivo .env:', result.error.message);
}

const app = express();
const port = 3000; 
const saltRounds = parseInt(process.env.SALT_ROUNDS, 10) || 10;

// Validar que las variables de PostgreSQL estén definidas
if (!process.env.PG_PASSWORD) {
  console.error('ERROR: PG_PASSWORD no está definida en el archivo .env');
  process.exit(1);
}

const db = new pg.Client({
    user: process.env.PG_USER,
    host: process.env.PG_HOST,
    database: process.env.PG_DATABASE,
    password: process.env.PG_PASSWORD,
    port: parseInt(process.env.PG_PORT, 10) || 5432,
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
//ACTUALIZAR PERFIL DE USUARIO
app.patch("/users/:id", async (req, res) => {
    console.log(`[UPDATE PROFILE] Params recibidos:`, req.params);
    console.log(`[UPDATE PROFILE] ID original (string): "${req.params.id}"`);
    const userId = parseInt(req.params.id, 10);
    console.log(`[UPDATE PROFILE] ID parseado (number): ${userId} (tipo: ${typeof userId})`);
    console.log(`[UPDATE PROFILE] Body recibido:`, req.body);

    // Validar que el ID sea un número válido
    if (isNaN(userId)) {
        console.log(`[UPDATE PROFILE] ID inválido: ${req.params.id}`);
        return res.status(400).json({
            success: false,
            message: "ID de usuario inválido"
        });
    }

    try {
        // Verificar que el usuario existe
        const userExist = await db.query(
            "SELECT * FROM users WHERE id = $1",
            [userId]
        );

        console.log(`[UPDATE PROFILE] Usuario encontrado: ${userExist.rows.length} filas`);

        if (userExist.rows.length < 1) {
            console.log(`[UPDATE PROFILE] Usuario ${userId} no encontrado en la base de datos`);
            return res.status(404).json({
                success: false,
                message: "Usuario no encontrado"
            });
        }

        // Si hay username en el body, verificar que no exista otro usuario con ese username
        if (req.body.username !== undefined) {
            const usernameCheck = await db.query(
                "SELECT * FROM users WHERE username = $1 AND id != $2",
                [req.body.username, userId]
            );

            if (usernameCheck.rows.length > 0) {
                return res.status(409).json({
                    success: false,
                    message: "El nombre de usuario que elegiste ya existe"
                });
            }
        }

        // Construir query UPDATE dinámico con solo los campos presentes en el body
        const allowedFields = ['full_name', 'email', 'phone_number', 'username'];
        const updates = [];
        const values = [];
        let paramIndex = 1;

        for (const field of allowedFields) {
            if (req.body[field] !== undefined) {
                updates.push(`${field} = $${paramIndex}`);
                values.push(req.body[field]);
                paramIndex++;
            }
        }

        if (updates.length === 0) {
            return res.status(400).json({
                success: false,
                message: "No hay campos para actualizar"
            });
        }

        // Agregar el userId al final para el WHERE
        values.push(userId);

        const updateQuery = `UPDATE users SET ${updates.join(', ')} WHERE id = $${paramIndex} RETURNING *`;
        
        const result = await db.query(updateQuery, values);

        res.status(200).json({
            success: true,
            message: "Perfil actualizado exitosamente",
            user: result.rows[0]
        });
    } catch (error) {
        console.error("Error al actualizar perfil:", error);
        res.status(500).json({
            success: false,
            message: "Error al actualizar el perfil. Inténtelo en otro momento"
        });
    }
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
app.get("/motorcycle/:id/observations", async (req, res) => {
    const motorcycleId = req.params.id;
    console.log(`[OBSERVATIONS] Petición recibida para motocicleta ID: ${motorcycleId}`);

    try {
        // Verificar que la motocicleta exista
        const motorcycleExist = await db.query(
            "SELECT * FROM motorcycles WHERE id = $1",
            [motorcycleId]
        );

        if (motorcycleExist.rows.length < 1) {
            console.log(`[OBSERVATIONS] Motocicleta ${motorcycleId} no encontrada`);
            return res.status(404).json({
                success: false,
                message: "Motocicleta no encontrada"
            });
        }

        // Consultar todas las observaciones de la motocicleta
        const observationsResult = await db.query(
            "SELECT * FROM observations WHERE motorcycle_id = $1 ORDER BY created_at DESC",
            [motorcycleId]
        );

        console.log(`[OBSERVATIONS] Encontradas ${observationsResult.rows.length} observaciones`);
        if (observationsResult.rows.length > 0) {
            console.log(`[OBSERVATIONS] Primera observación:`, JSON.stringify(observationsResult.rows[0], null, 2));
        }

        res.status(200).json(observationsResult.rows);
    } catch (error) {
        console.error("[OBSERVATIONS] Error al obtener observaciones:", error);
        res.status(500).json({
            success: false,
            message: "Error al obtener las observaciones. Inténtelo en otro momento"
        });
    }
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
app.post("/motorcycle/:id/maintenance", async (req, res) => {
    const motorcycleId = req.params.id;
    console.log(`[MAINTENANCE] Petición recibida para motocicleta ID: ${motorcycleId}`);
    console.log(`[MAINTENANCE] Body recibido:`, req.body);

    try {
        // Verificar que la motocicleta exista
        const motorcycleExist = await db.query(
            "SELECT * FROM motorcycles WHERE id = $1",
            [motorcycleId]
        );

        if (motorcycleExist.rows.length < 1) {
            return res.status(404).json({
                success: false,
                message: "Motocicleta no encontrada"
            });
        }

        // Extraer datos del cuerpo de la petición
        const { date, description, cost } = req.body;

        // Validar que la descripción esté presente y no esté vacía
        if (!description || typeof description !== 'string' || description.trim().length === 0) {
            return res.status(400).json({
                success: false,
                message: "La descripción es requerida y no puede estar vacía"
            });
        }

        // Validar que la fecha esté presente y sea válida
        if (!date || typeof date !== 'string') {
            return res.status(400).json({
                success: false,
                message: "La fecha es requerida"
            });
        }

        // Validar formato de fecha (YYYY-MM-DD)
        const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
        if (!dateRegex.test(date)) {
            return res.status(400).json({
                success: false,
                message: "Formato de fecha inválido. Debe ser YYYY-MM-DD"
            });
        }

        // Validar que el costo esté presente y sea un número válido
        if (cost === undefined || cost === null) {
            return res.status(400).json({
                success: false,
                message: "El costo es requerido"
            });
        }

        const costNumber = parseFloat(cost);
        if (isNaN(costNumber) || costNumber < 0) {
            return res.status(400).json({
                success: false,
                message: "El costo debe ser un número válido y no negativo"
            });
        }

        // Insertar en tabla maintenance
        await db.query(
            "INSERT INTO maintenance (motorcycle_id, date, description, cost) VALUES ($1, $2, $3, $4)",
            [
                motorcycleId,
                date,
                description.trim(),
                costNumber
            ]
        );

        res.status(201).json({
            success: true,
            message: "Mantenimiento registrado exitosamente"
        });
    } catch (error) {
        console.error("Error al registrar mantenimiento:", error);
        res.status(500).json({
            success: false,
            message: "Error al registrar el mantenimiento. Inténtelo en otro momento"
        });
    }
})
//REGISTRAR OBSERVACION
app.post("/motorcycle/:id/observations", async (req, res) => {
    const motorcycleId = req.params.id;

    try {
        // Verificar que la motocicleta exista
        const motorcycleExist = await db.query(
            "SELECT * FROM motorcycles WHERE id = $1",
            [motorcycleId]
        );

        if (motorcycleExist.rows.length < 1) {
            return res.status(404).json({
                success: false,
                message: "Motocicleta no encontrada"
            });
        }

        // Extraer datos del cuerpo de la petición
        const { observation } = req.body;

        // Validar que la observación esté presente y no esté vacía
        if (!observation || typeof observation !== 'string' || observation.trim().length === 0) {
            return res.status(400).json({
                success: false,
                message: "La observación es requerida y no puede estar vacía"
            });
        }

        // Obtener fecha actual en formato ISO
        const currentDate = new Date().toISOString();

        // Insertar en tabla observations
        await db.query(
            "INSERT INTO observations (motorcycle_id, observation, created_at, updated_at) VALUES ($1, $2, $3, $4)",
            [
                motorcycleId,
                observation.trim(),
                currentDate,
                currentDate
            ]
        );

        res.status(201).json({
            success: true,
            message: "Observación registrada exitosamente"
        });
    } catch (error) {
        console.error("Error al registrar observación:", error);
        res.status(500).json({
            success: false,
            message: "Error al registrar la observación. Inténtelo en otro momento"
        });
    }
})
//REGISTRAR MOTO DE USUARIO
app.post("/users/:id/motorcycles", async (req, res) => {
    const userId = req.params.id;

    try {
        // Verificar que el usuario exista
        const userExist = await db.query(
            "SELECT * FROM users WHERE id = $1",
            [userId]
        );

        if (userExist.rows.length < 1) {
            return res.status(404).json({
                success: false,
                message: "Usuario no encontrado"
            });
        }

        // Extraer datos del cuerpo de la petición
        const { motorcycle, soat, technomechanical } = req.body;

        if (!motorcycle || !soat || !technomechanical) {
            return res.status(400).json({
                success: false,
                message: "Faltan datos requeridos"
            });
        }

        // Insertar en tabla motorcycles
        const motorcycleResult = await db.query(
            "INSERT INTO motorcycles (make, model, year, power, torque, type, displacement, fuel_capacity, weight, user_id) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) RETURNING id",
            [
                motorcycle.make,
                motorcycle.model,
                motorcycle.year,
                motorcycle.power,
                motorcycle.torque,
                motorcycle.type,
                motorcycle.displacement || null,
                motorcycle.fuel_capacity,
                motorcycle.weight,
                userId
            ]
        );

        const motorcycleId = motorcycleResult.rows[0].id;

        // Insertar en tabla soat
        await db.query(
            "INSERT INTO soat (motorcycle_id, start_date, end_date, cost) VALUES ($1, $2, $3, $4)",
            [
                motorcycleId,
                soat.start_date,
                soat.end_date,
                soat.cost
            ]
        );

        // Insertar en tabla technomechanical
        await db.query(
            "INSERT INTO technomechanical (motorcycle_id, start_date, end_date, cost) VALUES ($1, $2, $3, $4)",
            [
                motorcycleId,
                technomechanical.start_date,
                technomechanical.end_date,
                technomechanical.cost
            ]
        );

        res.status(201).json({
            success: true,
            message: "Motocicleta registrada exitosamente"
        });
    } catch (error) {
        console.error("Error al registrar motocicleta:", error);
        res.status(500).json({
            success: false,
            message: "Error al registrar la motocicleta. Inténtelo en otro momento"
        });
    }
}) 
//REGISTRAR VIAJE DE USUARIO 
app.post("/users/:id/travels", (req, res) => {
    
})

// ELIMINAR MOTOCICLETA
app.delete("/motorcycles/:id", async (req, res) => {
    const motorcycleId = req.params.id

    try {
        await db.query("BEGIN")

        // Eliminar registros relacionados
        await db.query(
            "DELETE FROM maintenance WHERE motorcycle_id = $1",
            [motorcycleId]
        )
        await db.query(
            "DELETE FROM observations WHERE motorcycle_id = $1",
            [motorcycleId]
        )
        await db.query(
            "DELETE FROM technomechanical WHERE motorcycle_id = $1",
            [motorcycleId]
        )
        await db.query(
            "DELETE FROM soat WHERE motorcycle_id = $1",
            [motorcycleId]
        )

        const result = await db.query(
            "DELETE FROM motorcycles WHERE id = $1 RETURNING id",
            [motorcycleId]
        )

        await db.query("COMMIT")

        if (result.rowCount === 0) {
            return res.status(404).json({
                success: false,
                message: "Motocicleta no encontrada",
            })
        }

        res.status(200).json({
            success: true,
            message: "Motocicleta eliminada con éxito",
        })
    } catch (error) {
        await db.query("ROLLBACK")
        console.error("Error eliminando motocicleta:", error)
        res.status(500).json({
            success: false,
            message: "Error al eliminar la motocicleta",
        })
    }
})


app.listen(port, () => {
    console.log("server listening by port 3000")
})