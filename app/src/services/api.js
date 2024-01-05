import axios from 'axios';

const api = axios.create({
    baseURL: 'https://016c-191-243-238-175.ngrok-free.app/rest'
});


export default api;