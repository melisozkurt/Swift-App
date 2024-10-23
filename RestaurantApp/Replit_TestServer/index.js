const express = require("express");
const mongoose = require("mongoose");
const app = express();
const { v4: uuidv4 } = require("uuid");
const bodyParser = require("body-parser");

// MongoDB
mongoose
  .connect(process.env["mongo_api_key"], {
    useNewUrlParser: true, // Bu seçenek artık gerekmiyor ama bırakabilirsiniz, uyarı vermez.
    useUnifiedTopology: true, // Bu seçenek de artık gerekmiyor.
  })
  .then(() => console.log("MongoDB connected"))
  .catch((err) => console.error("MongoDB connection error:", err));

// reservation procedures
app.use(express.json());
app.use(bodyParser.json());

const reservationSchema = new mongoose.Schema({
  id: { type: String, required: true }, //UUID 
  userUuid: { type: String, required: true },
  restaurantId: String,
  restaurantName: String,
  name: String,
  surname: String,
  phone: String,
  numberOfGuests: Number,
  date: String,
  time: String,
});

const Reservation = mongoose.model("Reservation", reservationSchema);

// POST 
app.post("/reservations", async (req, res) => {
  const { userUuid, ...reservationData } = req.body;
  console.log("Received reservation data:", reservationData);
  console.log("User UUID:", userUuid);

  // new reservation with UUID
  const reservation = new Reservation({
    ...reservationData,
    userUuid, // Add userUuid to reservation data
    id: uuidv4(), // Generate a new UUID
  });
  try {
    await reservation.save();
    res
      .status(201)
      .json({ message: "Reservation created", id: reservation.id });
  } catch (err) {
    res.status(500).json({ message: "Error creating reservation", error: err });
  }
});

app.get("/reservations/restaurant/:restaurantId", async (req, res) => {
  const restaurantId = req.params.restaurantId;
  try {
    const reservations = await Reservation.find({ restaurantId });
    res.json(reservations);
  } catch (err) {
    res
      .status(500)
      .json({ message: "Error retrieving reservations", error: err });
  }
});

// GET
app.get("/reservations/user/:userUuid", async (req, res) => {
  const userUuid = req.params.userUuid;
  try {
    const reservations = await Reservation.find({ userUuid });
    res.json(reservations);
  } catch (err) {
    res
      .status(500)
      .json({ message: "Error retrieving reservations", error: err });
  }
});


// PUT 
app.put("/reservations/:id", async (req, res) => {
  const id = req.params.id; // Custom UUID id
  try {
    const updatedReservation = await Reservation.findOneAndUpdate(
      { id: id }, // custom `id` field for querying
      req.body,
      { new: true, runValidators: true } // providing and validating new data
    );
    if (updatedReservation) {
      res.send("Reservation updated");
    } else {
      res.status(404).send("Reservation not found");
    }
  } catch (err) {
    res.status(500).json({ message: "Error updating reservation", error: err });
  }
});


// DELETE
app.delete("/reservations/:id", async (req, res) => {
  const id = req.params.id;
  try {
    const deletedReservation = await Reservation.findOneAndDelete({ id: id });
    if (deletedReservation) {
      res.send("Reservation deleted");
    } else {
      res.status(404).send("Reservation not found");
    }
  } catch (err) {
    res.status(500).json({ message: "Error deleting reservation", error: err });
  }
});


const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
