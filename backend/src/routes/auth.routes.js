const express = require("express");
const { requireAuth } = require("../middlewares/requireAuth");

const router = express.Router();

router.get("/me", requireAuth, (req, res) => {
  const { appUser, roleNames, scope } = req.userContext;
  res.json({ user: appUser, roles: roleNames, scope });
});

module.exports = router;
