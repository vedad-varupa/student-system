import React, { useState } from 'react';

const StudentForm = () => {
  
  const [formData, setFormData] = useState({
    name: '',
    lastname: '',
  });

  const handleInputChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    try {
      const response = await fetch('/api/students', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(formData),
      });
         alert(formData);
      if (response.ok) {
        // Handle success
        console.log('Form submitted successfully');
      } else {
        // Handle error
        alert('Form submission failed');
      }
    } catch (error) {
      // Handle network error
      alert('Error occurred while submitting form:', error);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <div className="flex ml-[20px] gap-[20px] mt-[25px] relative">
      <label>
        
        <input placeholder="Firstname *" className="border-[2px] rounded-[6px] border-neutral-300 w-[310px] pl-[5px] text-[15px] h-[33px]"
          type="text"
          name="name"
          value={formData.name}
          onChange={handleInputChange}
        />
      </label>
      <br />
      <label>
        
        <input placeholder="Lastname *" className="border-[2px] rounded-[6px] border-neutral-300 w-[310px] pl-[5px] text-[15px] h-[33px]"
          type="lastname"
          name="lastname"
          value={formData.lastname}
          onChange={handleInputChange}
        />
      </label>
      </div>
      <br />
      <button className='bg-[#C02A1B] text-white w-[140px] h-[36px] ml-[550px] rounded-[6px] mt-[120px] text-[15px] hover:bg-violet-600 active:bg-violet-700 focus:outline-none focus:ring focus:ring-violet-300' type="submit">Submit</button>
    </form>
  );
};

export default StudentForm;

