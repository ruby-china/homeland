#include "StringTokenizer.h"

namespace csr { 

StringTokenizer::StringTokenizer(const std::string& _str, const std::string& _delim)
{

   if ((_str.length() == 0) || (_delim.length() == 0)) return;

   token_str = _str;
   delim     = _delim;

  /*
     Remove sequential delimiter
  */
   unsigned int curr_pos = 0;

   while(true)
   {
      if ((curr_pos = token_str.find(delim,curr_pos)) != std::string::npos)
      {
         curr_pos += delim.length();

         while(token_str.find(delim,curr_pos) == curr_pos)
         {
            token_str.erase(curr_pos,delim.length());
         }
      }
      else
       break;
   }

   /*
     Trim leading delimiter
   */
   if (token_str.find(delim,0) == 0)
   {
      token_str.erase(0,delim.length());
   }

   /*
     Trim ending delimiter
   */
   curr_pos = 0;
   if ((curr_pos = token_str.rfind(delim)) != std::string::npos)
   {
      if (curr_pos != (token_str.length() - delim.length())) return;
      token_str.erase(token_str.length() - delim.length(),delim.length());
   }

}


int StringTokenizer::countTokens()
{

   unsigned int prev_pos = 0;
   int num_tokens        = 0;

   if (token_str.length() > 0)
   {
      num_tokens = 0;

      unsigned int curr_pos = 0;
      while(true)
      {
         if ((curr_pos = token_str.find(delim,curr_pos)) != std::string::npos)
         {
            num_tokens++;
            prev_pos  = curr_pos;
            curr_pos += delim.length();
         }
         else
          break;
      }
      return ++num_tokens;
   }
   else
   {
      return 0;
   }

}


bool StringTokenizer::hasMoreTokens()
{
   return (token_str.length() > 0);
}


std::string StringTokenizer::nextToken()
{

   if (token_str.length() == 0)
     return "";

   std::string  tmp_str = "";
   unsigned int pos     = token_str.find(delim,0);

   if (pos != std::string::npos)
   {
      tmp_str   = token_str.substr(0,pos);
      token_str = token_str.substr(pos+delim.length(),token_str.length()-pos);
   }
   else
   {
      tmp_str   = token_str.substr(0,token_str.length());
      token_str = "";
   }

   return tmp_str;
}


int StringTokenizer::nextIntToken()
{
   return atoi(nextToken().c_str());
}


double StringTokenizer::nextFloatToken()
{
   return atof(nextToken().c_str());
}


std::string StringTokenizer::nextToken(const std::string& delimiter)
{
   if (token_str.length() == 0)
     return "";

   std::string  tmp_str = "";
   unsigned int pos     = token_str.find(delimiter,0);

   if (pos != std::string::npos)
   {
      tmp_str   = token_str.substr(0,pos);
      token_str = token_str.substr(pos + delimiter.length(),token_str.length() - pos);
   }
   else
   {
      tmp_str   = token_str.substr(0,token_str.length());
      token_str = "";
   }

   return tmp_str;
}


std::string StringTokenizer::remainingString()
{
   return token_str;
}


std::string StringTokenizer::filterNextToken(const std::string& filterStr)
{
   std::string  tmp_str    = nextToken();
   unsigned int currentPos = 0;

   while((currentPos = tmp_str.find(filterStr,currentPos)) != std::string::npos)
   {
      tmp_str.erase(currentPos,filterStr.length());
   }

   return tmp_str;
}

}; //namespace csr { 

