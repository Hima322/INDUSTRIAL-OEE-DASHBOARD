# INDUSTRIAL-OEE-DASHBOARD
A real-time Industrial OEE (Overall Equipment Effectiveness) Dashboard designed for manufacturing environments to monitor machine performance, downtime, and production efficiency. The system uses a Windows Service → PLC → Server → Dashboard architecture to ensure secure, stable, and continuous data flow.

# Project Overview

This project provides live visibility of production lines by collecting machine runtime, part counts, and alarm signals through a Windows Service connected to Mitsubishi PLCs using MC Protocol / Modbus / OPC Server. The service pushes data to the server, and the dashboard fetches it via REST APIs to display real-time OEE metrics: Availability, Performance, and Quality.

# Key Features

Windows Service for PLC communication and data collection

Real-time machine status (Running / Idle / Alarm)

Automated OEE calculation and shift-wise analytics

REST API-based data flow (Dashboard does NOT connect to PLC directly)

Historical logs, downtime tracking, and trend analysis

Responsive UI with Bootstrap, jQuery, AJAX

Export options (Excel/PDF) and email notifications

# Tech Stack

Backend: ASP.NET MVC, Web API, C#, Windows Service

Frontend: HTML, Bootstrap, jQuery, AJAX

Database: SQL Server

Hardware: Mitsubishi PLC (MC Protocol / OPC / Modbus)

# Architecture
PLC  →  Windows Service  →  Server/API  →  OEE Dashboard (Web)

# Use Cases

Monitoring machine performance in real time

Tracking downtime and reasons

Improving productivity using OEE insights

Supporting shop-floor decision making

# Status

Project tested and deployed in a live manufacturing environment with continuous 24/7 monitoring.
